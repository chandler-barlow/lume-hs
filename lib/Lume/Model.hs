module Lume.Model where

import Data.Natural

data OS = MacOS | Linux

instance Show OS where
  show (MacOS) = "macOS"
  show (Linux) = "linux"

-- | Denominated in kb
newtype Memory = Memory { getKB :: Natural }
  deriving newtype (Num, Integral, Eq, Ord)

-- | find the closest denom, and then
-- format the memory in kb to be that rep
--
-- Memory 1_000 -> "1KB"
-- Memory 1_000_000 -> "1MB"
-- Memory 1_123_150 -> "1.1232MB"
-- Memory 1_120_000 -> "1.12MB"
-- 
-- And so on...
-- 
instance Show Memory where
  show (Memory n) =
    let d = getMemDenom n
        n' = formatMem d n
    in show n' ++ show d

data MemDenom
  = KB
  | MB
  | GB
  | TB
  deriving Show

-- | Given a memory denomination and a double
-- turn it into a Memory rep
toMem :: MemDenom -> Double -> Memory
toMem d x = Memory (x * factor)
  where factor = denomAsNat d / denomAsNat KB

kb :: Natural -> Memory
kb = toMem KB

mb :: Natural -> Memory
mb = toMem MB

gb :: Natural -> Memory
gb = toMem GB

tb :: Natural -> Memory
tb = toMem TB

-- | Get the numeric rep of a denom
denomAsNat :: MemDenom -> Natural
denomAsNat =
  \case
    KB -> 10e3
    MB -> 10e6
    GB -> 10e9
    TB -> 10e12

-- | Given some amount of kb, what
-- denomination should it be in?
getMemDenom :: Natural -> MemDenom
getMemDenom kb
    | n <= denomAsNat MB = KB 
    | n <= denomAsNat GB = MB
    | n <= denomAsNat TB = GB
    | otherwise = TB

-- | truncate to N significant figures
truncate :: Natural -> Double -> Double
truncate n x = (fromIntegral . round $ x * n') / n'
  where n' = 10 ^ fromIntegral n

-- | Given some amount of memory in kb
-- and a denomination, return a double
-- that represents that memory rounded
-- to four significant figures.
formatMem :: MemDenom -> Natural -> Double
formatMem d kb = truncate 4 x
  where x = fromIntegral kb / factor
        factor = f d / f KB
        f = fromIntegral . denomAsNat

data Resolution = Resolution
  { width :: Natural
  , height :: Natural
  }

-- | Resolution 1080 720 -> "1080x720"
instance Show Resolution where
  show (Resolution w h) = concat [show w, "x", show h]

data Storage = SSD

instance Show Storage where
  show (SSD) = "ssd"

data VMConfig = VMConfig
  { name :: String
  , os :: OS
  , cpu :: Natural
  , memory :: Memory
  , diskSize :: Memory
  , display :: Maybe Resolution
  , ipsw :: undefined
  , storage :: Storage
  } deriving Show

data SharedDirectory = SharedDirectory
  { hostPath :: Filepath
  , readOnly :: Bool    
  } deriving Show

data RunVM = RunVM
  { noDisplay :: Bool
  , sharedDirectories :: [SharedDirectory]
  , recoveryMode :: Bool
  , storage :: Storage
  } deriving Show

data Status = Running | Stopped

instance Show Status where
  show =
    \case
      Running -> "running"
      Stopped -> "stopped"

data VMStatus = VMStatus
  { name :: String
  , os :: OS
  , cpu :: Natural
  , memory :: Memory
  , diskSize :: Memory
  , state :: Status
  } deriving Show

data Image = Image
  { image :: String
  , name :: String
  , registry :: Maybe String
  , organization :: Maybe String
  , storage :: Maybe Storage
  } deriving Show

data LumeConfig = LumeConfig
  { homeDirectory :: Filepath
  , cacheDirectory :: Filepath
  , cachingEnabled :: Bool
  }
