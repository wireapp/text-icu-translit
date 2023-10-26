module Main (main) where

import Data.Text qualified as T
import Data.Text.ICU.Translit (trans, transliterate)
import Lens.Family2 (over)
import Pipes (runEffect, (>->))
import Pipes.Group as PG (maps)
import Pipes.Prelude as Pipes (map)
import Pipes.Text as PT (lines)
import Pipes.Text.IO as PT (stdin, stdout)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [rule] ->
      go' $ fun (T.pack rule)
    _ ->
      error "Usage"
 where
  fun :: T.Text -> T.Text -> T.Text
  fun rule = transliterate (trans rule)

  go' f =
    runEffect $
      over PT.lines (PG.maps (>-> Pipes.map f)) PT.stdin
        >-> PT.stdout
