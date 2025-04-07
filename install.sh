if ! command -v brew &> /dev/null; then
	echo "Homebrew not found. Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew is alerdy installed."
fi

if ! command -v R &> /dev/null; then
	echo " R not found. Installing R..."
	brew install r
else 
	echo "R is already installed"
fi

echo "Installing R packages..."
Sudo Rscript -e "options(repos = c(CRAN = 'http://cran.rstudio.com/')); install.packages(c('KMsurv', 'survival', 'shiny', 'ggplot2', 'plyr', 'readxl'))"

sudo mv km-ui.sh /Users/local/bin/km-ui

echo "Installation complete!"



