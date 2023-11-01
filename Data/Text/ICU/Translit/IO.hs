module Data.Text.ICU.Translit.IO
  ( Transliterator,
    transliterator,
    transliterate,
  )
where

import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.Text (Text)
import Data.Text.Encoding qualified as T
import Data.Text.ICU.Translit.ICUHelper
  ( UChar,
    UErrorCode,
    handleError,
    handleFilledOverflowError,
  )
import Foreign

data UTransliterator

foreign import ccall "trans.h __hs_translit_open_trans"
  openTrans ::
    Ptr UChar -> Int -> Ptr UErrorCode -> IO (Ptr UTransliterator)

foreign import ccall "trans.h &__hs_translit_close_trans"
  closeTrans ::
    FunPtr (Ptr UTransliterator -> IO ())

foreign import ccall "trans.h __hs_translit_do_trans"
  doTrans ::
    Ptr UTransliterator ->
    Ptr UChar ->
    Int32 ->
    Int32 ->
    Ptr UErrorCode ->
    IO Int32

data Transliterator = Transliterator
  { transPtr :: ForeignPtr UTransliterator,
    transSpec :: Text
  }

instance Show Transliterator where
  show tr = "Transliterator " ++ show (transSpec tr)

-- we just assume little endian
transliterator :: Text -> IO Transliterator
transliterator spec = do
  let specStr :: ByteString = T.encodeUtf16LE spec
  BS.useAsCStringLen specStr $ \((castPtr @_ @Word16) -> ptr, (`div` 2) -> len) -> do
    q <- handleError $ openTrans ptr (fromIntegral len)
    ref <- newForeignPtr closeTrans q
    -- touchForeignPtr ref
    return $ Transliterator ref spec

transliterate :: Transliterator -> Text -> IO Text
transliterate tr txt = do
  let txtAsBs :: ByteString = T.encodeUtf16LE txt
  BS.useAsCStringLen txtAsBs \((castPtr @_ @Word16) -> ptr, (`div` 2) -> len) ->
    withForeignPtr (transPtr tr) $ \tr_ptr -> do
      handleFilledOverflowError
        ptr
        len
        ( \dptr dlen ->
            doTrans tr_ptr dptr (fromIntegral len) dlen
        )
        ( \dptr dlen ->
            T.decodeUtf16LE <$> BS.packCStringLen (castPtr dptr, dlen * 2)
        )
