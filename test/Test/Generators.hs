
module Test.Generators where


import           Control.Monad.Except
import           Control.Monad.IO.Class
import qualified Data.Map.Strict as M
import           Data.Word
import           Hedgehog (Gen, Property, forAll, property, tripping, (===))
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import           Test.Tasty (TestTree, testGroup)
import           Test.Tasty.Hedgehog

import           Cardano.API (Lovelace, deserialiseFromRawBytes)
import qualified Data.Aeson as Aeson

import           Cardano.API.Extended (AsType (AsVotingKeyPublic), VotingKeyPublic)
import           Cardano.CLI.Fetching
import           Contribution (Contributions)
import qualified Contribution as Contrib

-- votingFunds :: Gen VotingFunds
-- votingFunds = VotingFunds <$> Gen.map (Range.linear 0 16) ((,) <$> jaddr <*> lovelace)

-- Gen valid Bech32
-- https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#bech32

-- votingKeyPublic :: Gen VotingKeyPublic
-- votingKeyPublic = do
--   bs <- Gen.bytes (Range.linear 0 256)
--   case deserialiseFromRawBytes AsVotingKeyPublic bs of
--     Nothing  -> fail $ "Failed to create VotingKeyPublic from raw bytes: " <> show bs
--     Just key -> pure key

-- jaddr :: Gen JormungandrAddress

lovelace :: Gen Lovelace
lovelace = (fromIntegral . toInteger) <$> Gen.int64 (Range.linear 0 maxBound)

data OrderedPayload = OrderedPayload Int Word8
  deriving (Show)

instance Eq OrderedPayload where
  (OrderedPayload i1 _) == (OrderedPayload i2 _) = i1 == i2

instance Ord OrderedPayload where
  compare (OrderedPayload i1 _) (OrderedPayload i2 _) = compare i1 i2

orderedPayload :: Gen OrderedPayload
orderedPayload = OrderedPayload <$> Gen.int (Range.linear 0 maxBound) <*> Gen.word8 (Range.linear 0 maxBound)

-- | Generate random contributions.
--
-- Word8 was chosen because it is large enough to give us a decent
-- range of values, but small enough that generating random Word8's is
-- fairly likely to result in duplicate values, which are exactly the
-- values we are interested in testing. You are also more likely to
-- encounter overflow errors with such a small maximum bound.
contributions :: Gen (Contributions Word8 Word8 Word8)
contributions = Gen.recursive Gen.choice
  [ mempty ]
  [ Contrib.contribute <$> Gen.word8 (Range.linear 0 maxBound) <*> Gen.word8 (Range.linear 0 maxBound) <*> Gen.word8 (Range.linear 0 maxBound) <*> contributions
  , Contrib.withdraw <$> Gen.word8 (Range.linear 0 maxBound) <*> Gen.word8 (Range.linear 0 maxBound) <*> contributions
  , (<>) <$> contributions <*> contributions
  ]
