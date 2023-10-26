{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main (main) where

import Data.Char (ord)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.ICU qualified as U
import Data.Text.ICU.Translit (trans, transliterate)
import Test.Hspec
import Test.Hspec.QuickCheck
import Test.QuickCheck (Arbitrary (arbitrary, shrink), Property, elements, (===))
import Text.Printf (printf)

instance Arbitrary Text where
  arbitrary = fmap T.pack arbitrary
  shrink = fmap T.pack . shrink . T.unpack

newtype IdempTr = IdempTr Text deriving (Show)

instance Arbitrary IdempTr where
  arbitrary = elements transes0
   where
    transes0 = map IdempTr ["ru-en", "en-ru"]

hexUnicode :: Text -> Text
hexUnicode txt = T.pack $ concat [fmt c | c <- T.unpack txt]
 where
  fmt c = printf (if ord c < 0x10000 then "U+%04X" else "U+%X") (ord c)

prop_idemp :: (IdempTr, Text) -> Property
prop_idemp (IdempTr t, s) = transliterate tr (transliterate tr s) === transliterate tr s
 where
  tr = trans t

prop_toLower :: Text -> Property
prop_toLower t = U.toLower U.Root t === transliterate (trans "Lower") t

{-
NOTE: these two do not disagree and I think they're not supposed to
prop_toLower :: Text -> Property
prop_toLower t = T.toLower t === transliterate (trans "Lower") t
-}

prop_hexUnicode :: Text -> Property
prop_hexUnicode t = hexUnicode t === transliterate (trans "hex/unicode") t

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "properties" $ modifyMaxSuccess (const 10000) do
    prop "idempotence" prop_idemp
    prop "toLower" prop_toLower
    prop "hexUnicode" prop_hexUnicode
