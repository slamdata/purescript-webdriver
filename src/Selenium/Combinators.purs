module Selenium.Combinators where

import Prelude
import Control.Alt ((<|>))
import Control.Monad.Trans (lift)
import Data.Maybe (Maybe(), isJust, maybe)
import Data.Maybe.Unsafe (fromJust)
import Data.Either (Either(..), isRight, either)
import Control.Monad.Error.Class (throwError)
import Control.Monad.Eff.Exception (error, Error())
import Selenium.Monad
import Selenium.Types

-- | Retry computation until it successed but not more then `n` times
retry :: forall e o a. Int -> Selenium e o a -> Selenium e o a
retry n action = do
  res <- attempt action
  case res of
    Left e -> if n > one
              then retry (n - one) action
              else lift $ throwError $ error "To many retries"
    Right r -> pure r

-- | Tries to find element by string checks: css, xpath, id, name and classname
tryFind :: forall e o. String -> Selenium e o Element
tryFind probablyLocator =
  (byCss probablyLocator >>= findExact) <|>
  (byXPath probablyLocator >>= findExact) <|>
  (byId probablyLocator >>= findExact) <|>
  (byName probablyLocator >>= findExact) <|>
  (byClassName probablyLocator >>= findExact)

waitUntilJust :: forall e o a. Selenium e o (Maybe a) -> Int -> Selenium e o a
waitUntilJust check time = do
  wait (checker $ isJust <$> check) time
  fromJust <$> check

-- Tries to evaluate `Selenium` if it returns `false` after 500ms
checker :: forall e o a. Selenium e o Boolean -> Selenium e o Boolean
checker check = do
  res <- check
  if res
    then pure true
    else later 500 $ checker check

getElementByCss :: forall e o. String -> Selenium e o Element
getElementByCss cls =
  byCss cls
    >>= findElement
    >>= maybe (throwError $ error $ "There is no element matching css: " <> cls) pure

checkNotExistsByCss :: forall e o. String -> Selenium e o Unit
checkNotExistsByCss = contra <<< getElementByCss 

contra :: forall e o a. Selenium e o a -> Selenium e o Unit
contra check = do
  eR <- attempt check
  either
    (const $ pure unit)
    (const $ throwError $ error "check successed in contra") eR 

-- | takes value and repeatedly tries to evaluate it for timeout of ms (second arg)
-- | if it evaluates w/o error returns its value
-- | else throws error 
waiter :: forall e o a. Selenium e o a -> Int -> Selenium e o a
waiter getter timeout = do
  wait (checker $ (isRight <$> attempt getter)) timeout
  getter

waitExistentCss :: forall e o. String -> Int -> Selenium e o Element
waitExistentCss css timeout =
  waiter (getElementByCss css) timeout

waitNotExistentCss :: forall e o. String -> Int -> Selenium e o Unit
waitNotExistentCss css timeout =
  waiter (checkNotExistsByCss css) timeout


-- | Repeatedly tries to evaluate check (third arg) for timeout ms (first arg)
-- | finishes when check evaluates to true.
-- | If there is an error during check or it constantly returns `false`
-- | throws error with message (second arg)
await :: forall e o. Int -> Selenium e o Boolean -> Selenium e o Unit
await timeout check = do
  ei <- attempt $ wait (checker check) timeout
  case ei of
    Left _ -> throwError $ error "await has no success"
    Right _ -> pure unit 


awaitUrlChanged :: forall e o. String -> Selenium e o Boolean
awaitUrlChanged oldURL = checker $ (oldURL /=) <$> getCurrentUrl 
