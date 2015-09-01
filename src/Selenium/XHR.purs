module Selenium.XHR where

import Prelude
import Data.Either (either, Either(..))
import Data.Traversable (for)
import Selenium (executeStr)
import Selenium.Types
import Control.Monad.Aff (Aff())
import Control.Monad.Error.Class (throwError)
import Control.Monad.Eff.Exception (error)
import Data.Foreign (readBoolean, isUndefined, readArray)
import Data.Foreign.Class (readProp)
import Data.Foreign.NullOrUndefined (runNullOrUndefined)

-- | Start spy on xhrs. It defines global variable in browser
-- | and put information about to it. 
startSpying :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
startSpying driver = void $ 
  executeStr driver """
"use strict"
// If we have activated spying
if (window.__SELENIUM__) {
  // and it stopped
  if (!window.__SELENIUM__.isActive) {
    window.__SELENIUM__.spy();
  }
} else {
  var Selenium = {
      isActive: false,
      log: [],
      count: 0,
      spy: function() {
          // monkey patch
          var open = XMLHttpRequest.prototype.open;
          window.XMLHttpRequest.prototype.open =
              function(method, url, async, user, password) {
                  // we need this mark to update log after
                  // request is finished
                  this.__id = Selenium.count;
                  Selenium.log[this.__id] = {
                      method: method,
                      url: url,
                      async: async,
                      user: user,
                      password: password,
                      state: "stale"
                  };
                  Selenium.count++;
                  open.apply(this, arguments);
              };
          // another monkey patch
          var send = XMLHttpRequest.prototype.send;
          window.XMLHttpRequest.prototype.send =
              function(data) {
                  // this request can be deleted (this.clean() i.e.) 
                  if (Selenium.log[this.__id]) {
                      Selenium.log[this.__id].state = "opened";
                  }
                  // monkey pathc `onload` (I suppose it's useless to fire xhr
                  // without `onload` handler, but to be sure there is check for
                  // type of current value 
                  var m = this.onload;
                  this.onload = function() {
                      if (Selenium.log[this.__id]) {
                          Selenium.log[this.__id].state = "loaded";
                      }
                      if (typeof m == 'function') {
                          m();
                      }
                  };
                  send.apply(this, arguments);
              };
          // monkey patch `abort`          
          var abort = window.XMLHttpRequest.prototype.abort;
          window.XMLHttpRequest.prototype.abort = function() {
              if (Selenium.log[this.__id]) {
                  Selenium.log[this.__id].state = "aborted";
              }
              abort.apply(this, arguments);
          };
          this.isActive = true;
          // if we define it here we need not to make `send` global 
          Selenium.unspy = function() {
              this.active = false;
              window.XMLHttpRequest.send = send;
              window.XMLHttpRequest.open = open;
              window.XMLHttpRequest.abort = abort;
          };
      },
      // just clean log
      clean: function() {
          this.log = [];
      }
  };
  window.__SELENIUM__ = Selenium;
  Selenium.spy();
}
"""

-- | Return xhr's method to initial. Will not raise an error if hasn't been initiated
stopSpying :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
stopSpying driver = void $ executeStr driver """
if (window.__SELENIUM__) {
    window.__SELENIUM__.unspy();
}
"""

-- | Clean log. Will raise an error if spying hasn't been initiated
clearLog :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit 
clearLog driver = do 
  success <- executeStr driver """
  if (!window.__SELENIUM__) {
    return false;
  }
  else {
    window.__SELENIUM__.clean();
    return true;
  }
  """
  case readBoolean success of
    Right true -> pure unit
    _ -> throwError $ error "spying is inactive"

-- | Get recorded xhr stats. If spying has not been set will raise an error
getStats :: forall e. Driver -> Aff (selenium :: SELENIUM|e) (Array XHRStats)
getStats driver = do 
  log <- executeStr driver """
  if (!window.__SELENIUM__) {
    return undefined;
  }
  else {
    return window.__SELENIUM__.log;
  }
  """
  if isUndefined log
    then throwError $ error "spying is inactive"
    else pure unit
  either (const $ throwError $ error "incorrect log") pure do
    arr <- readArray log
    for arr \el -> do
      state <- readProp "state" el
      method <- readProp "method" el
      url <- readProp "url" el
      async <- readProp "async" el
      password <- runNullOrUndefined <$> readProp "password" el
      user <- runNullOrUndefined <$> readProp "user" el
      pure { state: state
           , method: method
           , url: url
           , async: async
           , password: password
           , user: user
           }
  


