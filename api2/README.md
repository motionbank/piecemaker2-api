# Goliath/ Grape API approach

 * https://github.com/postrank-labs/goliath
 * https://github.com/intridea/grape

## Installation

### with MySQL

```bundle install``` requires ```gem mysql2``` which needs mysql header files for building. Install MySQL with ```brew install mysql```. This will install the latest MySQL version (i.e. 5.6.12). The mysql2 gem doesnt like mysql 5.6.12 at all, we need MySQL version 5.6.10:

```bash
# http://stackoverflow.com/questions/3987683/homebrew-install-specific-version-of-formula

cd /usr/local
git checkout 48f7e86 /usr/local/Library/Formula/mysql.rb
brew unlink mysql
brew install mysql

# verify ... Distrib 5.6.10 ...not Distrib 5.6.12!
mysql --version

# finally run 
cd piecemaker/api2
bundle install
```


## Testing
```bash
cd piecmaker/api2
bundle install
rake test
```

