How enable to run .sh

Run all this commands before because is necessary to configure to you can install fish
``` shell 
# Fix npm cache permissions
sudo chown -R $(id -u):$(id -g) ~/.npm

# Fix nvm installation permissions
sudo chown -R $(id -u):$(id -g) ~/.nvm

# Fix Commitizen configuration
sudo chown $(id -u):$(id -g) ~/.czrc

# Fix Commitlint configuration
sudo chown -R $(id -u):$(id -g) ~/.config/commitlint

# Fix Husky hooks
sudo chown -R $(id -u):$(id -g) ~/.husky

# Fix Fish shell configuration
sudo chown -R $(id -u):$(id -g) ~/.config/fish

# Optional: Fix all .config permissions
sudo chown -R $(id -u):$(id -g) ~/.config

```

``` shell
 chmod +x <file-name-you-want-enable>.sh
```