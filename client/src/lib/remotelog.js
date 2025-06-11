function postLogs({ type, message }) {
  const body = JSON.stringify([getDeviceType(), message]);
  fetch("/logs", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body,
  }).catch((error) => console.error(`Error1:', ${error}`));
}

function getStackTrace() {
  const error = new Error();
  const stack = error.stack || "";
  const stackLines = stack.split("\n");
  // Adjust the index based on where you want to capture the stack trace from
  return stackLines[3] || "";
}

if (isMobileDevice()) {
  const _originalConsoleLog = console.log;
  const _originalConsoleError = console.error;
  const _originalConsoleWarn = console.warn;

  console.log = (...args) => {
    const message = `${args.join(" ")} | ${getStackTrace()}`;
    postLogs({ type: "log", message });
  };

  console.error = (...args) => {
    const message = `${args.join(" ")} | ${getStackTrace()}`;
    postLogs({ type: "error", message });
  };

  console.warn = (...args) => {
    const message = `${args.join(" ")} | ${getStackTrace()}`;
    postLogs({ type: "warn", message });
  };
}

function getDeviceType() {
  const userAgent = navigator.userAgent;
  const match = userAgent.match(/(Android|iPhone)/i);
  return match ? match[0] : "Other";
}

function isMobileDevice() {
  return /Mobi|Android/i.test(navigator.userAgent);
}
