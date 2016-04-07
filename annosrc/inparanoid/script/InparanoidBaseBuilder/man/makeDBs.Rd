\name{makeDBs}

\alias{makeDBs}

\title{
  Builds the individual DBs for making Inparanoid Packages.
}
\description{
  Builds the individual DBs for building the databases needed for the
  Inparanoid packages.
}
\usage{
  makeDBs(dataDir, metaDir)
}
\arguments{  
  \item{dataDir}{directory where the source inparanoid.sqlite DB is}
  \item{metaDir}{the metadata.sqlite DB, this is just a DB where we
  store metadata about the various packages.}
}
\details{
  This function is just one more step in the processing of the Inparanoid
  files into their final source DBs.
}
\value{ A SQLite DB is produced but this is not returned from the function }
\author{
  M. Carlson 
}
\examples{
\dontrun{  makeDBs(dataDir=".")}
}
