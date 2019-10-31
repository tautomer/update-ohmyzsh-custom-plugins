# oh-my-zsh plugin to update all custom plugins and themes

This plugin updates every git repo in the `$ZSH_CUSTOM` folder.

## Install & Run

Clone this repo to your local

```zsh
git clone https://github.com/tautomer/update-ohmyzsh-custom-plugins.git $ZSH_CUSTOM/plugins/update-custom-plugins
```

To use the plugin, add it in your plugin list in your `.zshrc`

```zsh
plugins=(... update-custom-plugins ...)
```

Run `update-custom-plugins` to perform the update.

## TO-DO

The plugin is in very early stage which barely does its job. There are many things in my mind.

- [x] Check if the repo really need an update before `git pull`.

- [x] Check if it is safe to pull from remote. Abort if there are conflicts.

- [ ] More elegant output message.

- [ ] Better script?