\name{makeSrcDB}

\alias{makeSrcDB}

\title{
  Builds the Src DB for making Inparanoid Packages.
}
\description{
  Builds the Src DB for building the databases needed for the Inparanoid
  packages.
}
\usage{
  makeSrcDB(dataDir)
}
\arguments{  
  \item{dataDir}{directory where the Inparanoid data files reside}
}
\details{
  This function is just one step in the processing of the Inparanoid
  files into the initial source DB.
}
\value{ A SQLite DB is produced but this is not returned from the function }
\author{
  M. Carlson 
}
\examples{
\dontrun{  makeSrcDB(dataDir="./29-Apr-2009/IPDATA/")}
}
