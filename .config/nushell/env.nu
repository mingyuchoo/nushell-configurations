
def create_left_prompt [] {
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}


$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }


$env.PROMPT_INDICATOR = {|| "🦀〉 " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "🦀〉 " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }


$env.EDITOR = nvim


$env.HOME_BIN      = $env.HOME | path join bin
$env.DOT_BUN_BIN   = $env.HOME | path join .bun bin
$env.DOT_CARGO_BIN = $env.HOME | path join .cargo bin
$env.DOT_GHCUP_BIN = $env.HOME | path join .ghcup bin
$env.DOT_LOCAL_BIN = $env.HOME | path join .local bin
$env.DOT_RD_BIN    = $env.HOME | path join .local bin


$env.PATH = $env.PATH | split row (char esep)
  | append /usr/local/bin
  | append $env.HOME_BIN
  | append $env.DOT_BUN_BIN
  | append $env.DOT_CARGO_BIN
  | append $env.DOT_GHCUP_BIN
  | append $env.DOT_LOCAL_BIN
  | append $env.DOT_RD_BIN
  | uniq # filter so the paths are unique


$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}


$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]


$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]
