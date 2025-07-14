/**
 * Keyboard Daemon
 *
 * A macOS daemon that provides enhanced keyboard functionality:
 * - Caps Lock timeout behavior: Quick press (<500ms) = Escape, Hold = Control
 * - Right-Option app launching: Right-Option + {s,n,r,m,x,t} launches apps
 * - Right-Option scrolling: Right-Option + {h,j,k,l} for directional scrolling
 *
 * Requires Input Monitoring permissions to function properly.
 */

#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/hid/IOHIDManager.h>
#include <IOKit/hid/IOHIDValue.h>
#include <mach/mach_time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <unistd.h>

// HID usage codes (USB HID specification)
#define CAPS_LOCK_USAGE 0x39
#define RIGHT_OPTION_USAGE 0xE6
#define KEY_H_USAGE 0x0B
#define KEY_J_USAGE 0x0D
#define KEY_K_USAGE 0x0E
#define KEY_L_USAGE 0x0F
#define KEY_M_USAGE 0x10
#define KEY_N_USAGE 0x11
#define KEY_R_USAGE 0x15
#define KEY_S_USAGE 0x16
#define KEY_T_USAGE 0x17
#define KEY_X_USAGE 0x1B

// Virtual key codes for macOS key events
#define ESCAPE_KEYCODE 0x35
#define CONTROL_KEYCODE 0x3B

// Threshold in milliseconds to distinguish tap vs hold
#define HOLD_THRESHOLD_MS 500

// Scroll wheel sensitivity
#define SCROLL_UNITS 1

/**
 * Structure to track the current state of the Caps Lock key
 */
typedef struct {
  uint64_t press_time; // Mach absolute time when key was pressed
  bool is_pressed;     // Whether the key is currently held down
  bool control_sent;   // Whether a control key event has been sent
} CapsLockState;

/**
 * Structure to track the current state of the Right-Option key
 */
typedef struct {
  bool is_pressed;     // Whether the key is currently held down
} RightOptionState;

/**
 * Structure to track the current state of scroll keys
 */
typedef struct {
  bool h_pressed;      // Whether h key is currently held down
  bool j_pressed;      // Whether j key is currently held down
  bool k_pressed;      // Whether k key is currently held down
  bool l_pressed;      // Whether l key is currently held down
  CFRunLoopTimerRef scroll_timer; // Timer for continuous scrolling
} ScrollState;

// Global state for caps lock key tracking
static CapsLockState caps_state = {0, false, false};
// Global state for right-option key tracking
static RightOptionState right_option_state = {false};
// Global state for scroll key tracking
static ScrollState scroll_state = {false, false, false, false, NULL};
// System timebase information for time conversion
static mach_timebase_info_data_t timebase_info;

/**
 * Logs a message to the system log with daemon prefix
 * @param message The message to log
 */
void log_message(const char *message) {
  syslog(LOG_INFO, "KeyboardDaemon: %s", message);
}

/**
 * Converts Mach absolute time to milliseconds
 * @param mach_time Mach absolute time value
 * @return Time in milliseconds
 */
uint64_t mach_time_to_milliseconds(uint64_t mach_time) {
  return (mach_time * timebase_info.numer) / (timebase_info.denom * 1000000);
}

/**
 * Sends a virtual key event (press or release)
 * @param keycode The virtual key code to send
 * @param key_down true for key press, false for key release
 */
void send_virtual_key(CGKeyCode keycode, bool key_down) {
  CGEventRef event = CGEventCreateKeyboardEvent(NULL, keycode, key_down);
  if (event) {
    CGEventSetFlags(event, 0); // Clear any modifier flags
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
  }
}

/**
 * Handles when the Caps Lock key is pressed down
 * Records the press time and initializes state for tracking
 */
void handle_caps_lock_press() {
  caps_state.press_time = mach_absolute_time();
  caps_state.is_pressed = true;
  caps_state.control_sent = false;

  log_message("Caps Lock pressed");
}

/**
 * Handles when the Caps Lock key is released
 * Determines whether to send Escape (short press) or release Control (long
 * press/combo)
 */
void handle_caps_lock_release() {
  if (!caps_state.is_pressed)
    return;

  uint64_t release_time = mach_absolute_time();
  uint64_t hold_duration =
      mach_time_to_milliseconds(release_time - caps_state.press_time);

  caps_state.is_pressed = false;

  // Short press without any combo = Escape key
  if (hold_duration < HOLD_THRESHOLD_MS && !caps_state.control_sent) {
    send_virtual_key(ESCAPE_KEYCODE, true);
    send_virtual_key(ESCAPE_KEYCODE, false);
    log_message("Sending Escape key");
  }
  // Long press or combo detected = release Control key
  else if (caps_state.control_sent) {
    send_virtual_key(CONTROL_KEYCODE, false);
    log_message("Releasing Control key");
  }

  caps_state.control_sent = false;
}

/**
 * Handles when any other key is pressed while Caps Lock is held
 * Converts the held Caps Lock into a Control modifier
 */
void handle_other_key_press() {
  if (caps_state.is_pressed && !caps_state.control_sent) {
    send_virtual_key(CONTROL_KEYCODE, true);
    caps_state.control_sent = true;
    log_message("Sending Control key (combo detected)");
  }
}

/**
 * Sends a scroll wheel event
 * @param delta_x Horizontal scroll amount (positive = right, negative = left)
 * @param delta_y Vertical scroll amount (positive = up, negative = down)
 */
void send_scroll_event(int32_t delta_x, int32_t delta_y) {
  CGEventRef event = CGEventCreateScrollWheelEvent(
      NULL, kCGScrollEventUnitLine, 2, delta_y, delta_x);
  if (event) {
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
  }
}

/**
 * Launches an application using the open command
 * @param app_name The name of the application to launch
 */
void launch_app(const char *app_name) {
  char command[256];
  snprintf(command, sizeof(command), "open -a '%s'", app_name);
  
  if (system(command) == 0) {
    char log_msg[256];
    snprintf(log_msg, sizeof(log_msg), "Launched %s", app_name);
    log_message(log_msg);
  } else {
    char log_msg[256];
    snprintf(log_msg, sizeof(log_msg), "Failed to launch %s", app_name);
    log_message(log_msg);
  }
}

/**
 * Focuses the frontmost window and moves cursor to its center for scrolling
 * This ensures scroll events are sent to the active window, not the old cursor position
 */
void focus_window_for_scrolling() {
  CFArrayRef window_list = CGWindowListCopyWindowInfo(
      kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements,
      kCGNullWindowID);
  
  if (window_list && CFArrayGetCount(window_list) > 0) {
    CFDictionaryRef window = CFArrayGetValueAtIndex(window_list, 0);
    CFDictionaryRef bounds = CFDictionaryGetValue(window, kCGWindowBounds);
    
    if (bounds) {
      CGRect window_rect;
      if (CGRectMakeWithDictionaryRepresentation(bounds, &window_rect)) {
        CGPoint center = {
          window_rect.origin.x + window_rect.size.width / 2,
          window_rect.origin.y + window_rect.size.height / 2
        };
        
        CGWarpMouseCursorPosition(center);
        log_message("Moved cursor to focused window center");
      }
    }
  }
  
  if (window_list) CFRelease(window_list);
}

/**
 * Timer callback for continuous scrolling
 * Called repeatedly while scroll keys are held down
 */
void scroll_timer_callback(CFRunLoopTimerRef timer __attribute__((unused)), void *info __attribute__((unused))) {
  if (scroll_state.h_pressed) {
    send_scroll_event(-SCROLL_UNITS, 0);
  }
  if (scroll_state.j_pressed) {
    send_scroll_event(0, -SCROLL_UNITS);
  }
  if (scroll_state.k_pressed) {
    send_scroll_event(0, SCROLL_UNITS);
  }
  if (scroll_state.l_pressed) {
    send_scroll_event(SCROLL_UNITS, 0);
  }
}

/**
 * Starts continuous scrolling timer
 * Called when first scroll key is pressed
 */
void start_continuous_scrolling() {
  if (!scroll_state.scroll_timer) {
    CFRunLoopTimerContext context = {0, NULL, NULL, NULL, NULL};
    scroll_state.scroll_timer = CFRunLoopTimerCreate(
        kCFAllocatorDefault,
        CFAbsoluteTimeGetCurrent() + 0.1, // Start after 100ms
        0.05, // Repeat every 50ms
        0, 0, scroll_timer_callback, &context);
    
    if (scroll_state.scroll_timer) {
      CFRunLoopAddTimer(CFRunLoopGetCurrent(), scroll_state.scroll_timer, kCFRunLoopDefaultMode);
      log_message("Started continuous scrolling timer");
    }
  }
}

/**
 * Stops continuous scrolling timer
 * Called when all scroll keys are released
 */
void stop_continuous_scrolling() {
  if (scroll_state.scroll_timer) {
    CFRunLoopTimerInvalidate(scroll_state.scroll_timer);
    CFRelease(scroll_state.scroll_timer);
    scroll_state.scroll_timer = NULL;
    log_message("Stopped continuous scrolling timer");
  }
}

/**
 * Checks if any scroll keys are currently pressed
 * @return true if any scroll key is pressed, false otherwise
 */
bool any_scroll_key_pressed() {
  return scroll_state.h_pressed || scroll_state.j_pressed || 
         scroll_state.k_pressed || scroll_state.l_pressed;
}

/**
 * Handles Right-Option key press
 */
void handle_right_option_press() {
  right_option_state.is_pressed = true;
  log_message("Right-Option pressed");
}

/**
 * Handles Right-Option key release
 */
void handle_right_option_release() {
  right_option_state.is_pressed = false;
  
  // Stop continuous scrolling and reset scroll state when Right-Option is released
  if (any_scroll_key_pressed()) {
    scroll_state.h_pressed = false;
    scroll_state.j_pressed = false;
    scroll_state.k_pressed = false;
    scroll_state.l_pressed = false;
    stop_continuous_scrolling();
    log_message("Reset scroll state on Right-Option release");
  }
  
  log_message("Right-Option released");
}

/**
 * Handles Right-Option + letter key combinations (key press)
 * @param usage The HID usage code of the letter key
 */
void handle_right_option_combo_press(uint32_t usage) {
  if (!right_option_state.is_pressed) {
    return;
  }
  
  switch (usage) {
    // App launching shortcuts
    case KEY_S_USAGE:
      launch_app("Safari");
      // Focus window for potential scrolling after app switch
      focus_window_for_scrolling();
      break;
    case KEY_N_USAGE:
      launch_app("Notes");
      focus_window_for_scrolling();
      break;
    case KEY_R_USAGE:
      launch_app("Reminders");
      focus_window_for_scrolling();
      break;
    case KEY_M_USAGE:
      launch_app("Music");
      focus_window_for_scrolling();
      break;
    case KEY_T_USAGE:
      launch_app("Terminal");
      focus_window_for_scrolling();
      break;
    case KEY_X_USAGE:
      launch_app("Xcode");
      focus_window_for_scrolling();
      break;
    
    // Scrolling shortcuts - start continuous scrolling
    case KEY_H_USAGE:
      if (!scroll_state.h_pressed) {
        scroll_state.h_pressed = true;
        focus_window_for_scrolling();
        send_scroll_event(-SCROLL_UNITS, 0);
        if (scroll_state.scroll_timer == NULL) {
          start_continuous_scrolling();
        }
        log_message("Started scrolling left");
      }
      break;
    case KEY_J_USAGE:
      if (!scroll_state.j_pressed) {
        scroll_state.j_pressed = true;
        focus_window_for_scrolling();
        send_scroll_event(0, -SCROLL_UNITS);
        if (scroll_state.scroll_timer == NULL) {
          start_continuous_scrolling();
        }
        log_message("Started scrolling down");
      }
      break;
    case KEY_K_USAGE:
      if (!scroll_state.k_pressed) {
        scroll_state.k_pressed = true;
        focus_window_for_scrolling();
        send_scroll_event(0, SCROLL_UNITS);
        if (scroll_state.scroll_timer == NULL) {
          start_continuous_scrolling();
        }
        log_message("Started scrolling up");
      }
      break;
    case KEY_L_USAGE:
      if (!scroll_state.l_pressed) {
        scroll_state.l_pressed = true;
        focus_window_for_scrolling();
        send_scroll_event(SCROLL_UNITS, 0);
        if (scroll_state.scroll_timer == NULL) {
          start_continuous_scrolling();
        }
        log_message("Started scrolling right");
      }
      break;
      
    default:
      break;
  }
}

/**
 * Handles Right-Option + letter key combinations (key release)
 * @param usage The HID usage code of the letter key
 */
void handle_right_option_combo_release(uint32_t usage) {
  switch (usage) {
    // Scrolling shortcuts - stop continuous scrolling
    case KEY_H_USAGE:
      scroll_state.h_pressed = false;
      log_message("Stopped scrolling left");
      break;
    case KEY_J_USAGE:
      scroll_state.j_pressed = false;
      log_message("Stopped scrolling down");
      break;
    case KEY_K_USAGE:
      scroll_state.k_pressed = false;
      log_message("Stopped scrolling up");
      break;
    case KEY_L_USAGE:
      scroll_state.l_pressed = false;
      log_message("Stopped scrolling right");
      break;
      
    default:
      break;
  }
  
  // Stop continuous scrolling if no scroll keys are pressed
  if (!any_scroll_key_pressed()) {
    stop_continuous_scrolling();
  }
}

/**
 * Callback function for HID input events
 * Processes keyboard input and routes Caps Lock, Right-Option, and other key events
 * appropriately
 *
 * @param context Unused context parameter
 * @param result Unused result parameter
 * @param sender Unused sender parameter
 * @param value The HID value containing key event data
 */
void hid_input_callback(void *context __attribute__((unused)),
                        IOReturn result __attribute__((unused)),
                        void *sender __attribute__((unused)),
                        IOHIDValueRef value) {
  IOHIDElementRef element = IOHIDValueGetElement(value);
  uint32_t usage_page = IOHIDElementGetUsagePage(element);
  uint32_t usage = IOHIDElementGetUsage(element);
  long pressed = IOHIDValueGetIntegerValue(value);

  // Only process keyboard/keypad events
  if (usage_page != kHIDPage_KeyboardOrKeypad)
    return;

  if (usage == CAPS_LOCK_USAGE) {
    // Handle Caps Lock press/release
    if (pressed) {
      handle_caps_lock_press();
    } else {
      handle_caps_lock_release();
    }
  } else if (usage == RIGHT_OPTION_USAGE) {
    // Handle Right-Option press/release
    if (pressed) {
      handle_right_option_press();
    } else {
      handle_right_option_release();
    }
  } else {
    // Handle Right-Option + letter key combinations
    if (usage == KEY_S_USAGE || usage == KEY_N_USAGE ||
        usage == KEY_R_USAGE || usage == KEY_M_USAGE || usage == KEY_T_USAGE ||
        usage == KEY_X_USAGE || usage == KEY_H_USAGE || usage == KEY_J_USAGE ||
        usage == KEY_K_USAGE || usage == KEY_L_USAGE) {
      
      if (pressed) {
        handle_right_option_combo_press(usage);
      } else {
        handle_right_option_combo_release(usage);
      }
    }
    
    // Handle other key presses for Caps Lock combos (USB HID keyboard usage range)
    // This range covers A-Z, 0-9, modifiers, and special keys
    if (pressed && usage >= 0x04 && usage <= 0xE7) {
      handle_other_key_press();
    }
  }
}

/**
 * Creates a matching dictionary to filter for keyboard devices
 * This tells the HID manager to only monitor keyboard input devices
 *
 * @return A CFMutableDictionaryRef for keyboard device matching, or NULL on
 * failure
 */
CFMutableDictionaryRef create_keyboard_matching_dictionary() {
  CFMutableDictionaryRef dict = CFDictionaryCreateMutable(
      kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks,
      &kCFTypeDictionaryValueCallBacks);

  if (dict) {
    // Create usage page and usage values for keyboard devices
    CFNumberRef usage_page = CFNumberCreate(
        kCFAllocatorDefault, kCFNumberIntType, &(int){kHIDPage_GenericDesktop});
    CFNumberRef usage = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType,
                                       &(int){kHIDUsage_GD_Keyboard});

    // Set the matching criteria for keyboard devices
    CFDictionarySetValue(dict, CFSTR(kIOHIDDeviceUsagePageKey), usage_page);
    CFDictionarySetValue(dict, CFSTR(kIOHIDDeviceUsageKey), usage);

    // Clean up the CFNumberRef objects
    CFRelease(usage_page);
    CFRelease(usage);
  }

  return dict;
}

/**
 * Sets up the HID manager to monitor keyboard input
 * Configures device matching, callbacks, and opens the HID manager for input
 * monitoring
 */
void setup_hid_manager() {
  // Create the HID manager
  IOHIDManagerRef manager =
      IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
  if (!manager) {
    log_message("Failed to create HID manager");
    return;
  }

  // Set up device matching to only monitor keyboards
  CFMutableDictionaryRef keyboard_dict = create_keyboard_matching_dictionary();
  if (keyboard_dict) {
    IOHIDManagerSetDeviceMatching(manager, keyboard_dict);
    CFRelease(keyboard_dict);
  }

  // Register our input callback function
  IOHIDManagerRegisterInputValueCallback(manager, hid_input_callback, NULL);

  // Schedule the HID manager with the current run loop
  IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(),
                                  kCFRunLoopDefaultMode);

  // Open the HID manager to begin receiving input events
  IOReturn ret = IOHIDManagerOpen(manager, kIOHIDOptionsTypeNone);
  if (ret != kIOReturnSuccess) {
    log_message("Failed to open HID manager");
    CFRelease(manager);
    return;
  }

  log_message("HID manager initialized successfully");
}

/**
 * Signal handler for graceful shutdown
 * Handles SIGTERM and SIGINT to cleanly exit the daemon
 *
 * @param signum The signal number (unused)
 */
void signal_handler(int signum __attribute__((unused))) {
  log_message("Received signal, shutting down");
  
  // Clean up scroll timer before exit
  if (scroll_state.scroll_timer) {
    CFRunLoopTimerInvalidate(scroll_state.scroll_timer);
    CFRelease(scroll_state.scroll_timer);
    scroll_state.scroll_timer = NULL;
  }
  
  exit(0);
}

/**
 * Main entry point for the Keyboard daemon
 * Initializes logging, time conversion, signal handling, and the HID manager
 *
 * @return 0 on success, 1 on failure
 */
int main() {
  // Initialize system logging
  openlog("KeyboardDaemon", LOG_PID, LOG_DAEMON);
  log_message("Starting Keyboard daemon");

  // Get system timebase information for time conversions
  if (mach_timebase_info(&timebase_info) != KERN_SUCCESS) {
    log_message("Failed to get timebase info");
    return 1;
  }

  // Set up signal handlers for graceful shutdown
  signal(SIGTERM, signal_handler);
  signal(SIGINT, signal_handler);

  // Initialize HID monitoring
  setup_hid_manager();

  // Enter the main event loop
  log_message("Entering run loop");
  CFRunLoopRun();

  // Clean up logging (this line should never be reached)
  closelog();
  return 0;
}
