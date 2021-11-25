window.st = {
  api: {
    trackEvent: function (eventName, dataObject) {
      if (typeof amplitude !== 'undefined') {
        amplitude.getInstance().logEvent(eventName, dataObject);
      }
    }
  }
};