{- Module      : Data.Matrix
-- Copyright   : (c) Isaac H. Lopez Diaz 2024
-- License     : BSD-style
--
-- Maintainer  : isaac.lopez@upr.edu
-- Stability   : experimental
-- Portability : non-portable
-- 
-- Native matrices
-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiWayIf #-}

module Data.Matrix where

-- Matrix data structure
data Matrix a = Matrix 
    { row :: Int 
    , col :: Int 
    , elems :: Num a => [[a]]
    }

{- Matrix Creation -}
-- | empty matrix construction
empty :: Matrix a
empty = Matrix 0 0 []

-- | Given a row and a column with a list of
-- elements a matrix data structure is returned.
-- If the list is empty the zero matrix is returned
-- Otherwise matrix is built
matrix :: Int -> Int -> [a] -> Matrix a
matrix r c [] = Matrix r c []
matrix r c m
    | r*c /= length m = error "Matrix indices do not match list length"
    | otherwise = 
        let r1 = take c m
         in Matrix r c ([r1] ++ loop c (drop c m))
        where
            loop _ [] = []
            loop n xs = [take n xs] ++ loop n (drop c xs) 


-- | transposition
-- transposes the matrices elements
transpose :: (Eq a, Num a) => Matrix a -> Matrix a
transpose (Matrix r c elems) = 
    if r == 1 
        then (Matrix c r elems)
        else (Matrix c r (transposeIter elems []))
    where 
        transposeIter xs res =
            let hds = map head xs
                tls = map tail xs
             in 
                if concat tls == [] 
                    then res ++ [hds]
                    else transposeIter tls (res ++ [hds])

{- | addition
addition :: Matrix a -> Matrix a -> Matrix a
addition = undefined

-- | scalar-matrix mult
scalarMult :: Num a => a -> Matrix a -> Matrix a
scalarMult = undefined

-- | matrix-matrix mult
multiplication :: Matrix a -> Matrix a -> Matrix a
multiplication = undefined
-}
-- vector dot product
vdot :: Num a => Matrix a -> Matrix a -> a
vdot (Matrix r1 c1 v1) (Matrix r2 c2 v2) =
    if 
        | c1 == 1 && c2 == 1 -> 
            if r1 /= r2
                then error "Vector dot product expects vectors of the same dimension" 
                else loop r1 v1 v2 0 0
        | r1 == 1 && r2 == 1 -> 
            if c1 /= c2
                then error "Vector dot product expects vectors of the same dimension" 
                else loop c1 v1 v2 0 0
        | otherwise -> error "Vector has higher dimension to perform dot product"
    where
        loop n x y i c =
            if i == n
                then c
                else
                    let xi = (x !! 0) !! i
                        yi = (y !! 0) !! i
                        c' = c + xi * yi
                     in loop n x y (i+1) c'

saxpy :: Num a => Matrix a  -> Matrix a -> a -> Matrix a
saxpy (Matrix r1 c1 v1) (Matrix r2 c2 v2) alpha =
    if
        | r1 == 1 && r2 == 1 -> 
            if c1 /= c2
                then error "Vector dot product expects vectors of the same dimension" 
                else
                    let result = loop v1 v2 c1 alpha 0 []
                     in matrix r1 c1 result
        | c1 == 1 && c2 == 1-> 
            if r1 /= r2
                then error "Vector dot product expects vectors of the same dimension" 
                else
                    let result = loop v1 v1 r1 alpha 0 []
                     in matrix r1 c1 result
        | otherwise -> error "Vector scalar multiplication has higher dimension"
    where
        loop x y n a i res =
            if i == n 
                then res
                else
                    let xi = (x !! 0) !! i
                        yi = (y !! 0) !! i
                        yi' = yi + a * xi
                     in loop x y n a (i+1) (res ++ [yi'])
