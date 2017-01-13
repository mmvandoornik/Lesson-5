cloud2NA <- function(x, y){
  x[y != 0] <- NA
  return(x)
}

ndviFunc <- function(x, y) {
  ndvi <- (y - x) / (x + y)
  return(ndvi)
}

difference <- function(x){
  dif <- x[[2]] - x[[1]]
  return(dif)
}