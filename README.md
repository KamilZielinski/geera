# Geera

Geera lets you quickly change branches based on Jira tickets without thinking about their names. It can find a existing branch or create new if needed.

## Requirements
- Linux or MacOS
- GIT client installed

## Installation

TODO: Write installation instructions here

## Usage

### Configuration

1. Go to [Jira API token](https://id.atlassian.com/manage-profile/security/api-tokens) and create new API token
2. Run `geera configure` and finish configuration
```bash
$ geera configure
[Geera v0.1.0]
Connect your Jira account by passing your company domain and credentials:

Domain (from url: https://XXXXX.atlassian.net) where XXXXX is your company domain: geera
Jira login: email@example.com
Jira API token: (paste your token here)
Select your teams\' board:
1. GEE - Geera project
33. VIP - Very Interesting Project
66. GAA - Great And Awesome

# Select your project by passing a number and confirm
1 
New configuration has been saved at /Users/username/.geera/config.env
```

3. Switch to a branch or create new
```bash
# Branch already exists in Git (locally or remote)
$ geera 1234
Switched to branch 'task/GEE-1234-implement-cli'

# Branch exists in Jira but not in Git so we create it
$ geera 888
Switched to a new branch 'sub-task/GEE-888-add-top-readme-description'

# Branch doesn't exist locally and in Jira
$ geera 871283712831839
Given issue [GEE-871283712831839] doesn\'t exist
```

## Available commands
- `$ geera configure` - lets you configure geera. Config is store in `~/.geera/config.env`
- `$ geera XXX` - replacing XXX with a Jira issue number lets you find Jira/Git task and checkout on it

## Contributing

1. Fork it (<https://github.com/KamilZielinski/geera/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kamil Zieliński](https://github.com/KamilZielinski) - creator and maintainer
