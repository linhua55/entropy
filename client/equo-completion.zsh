#compdef equo

local curcontext="$curcontext" state line cmds packages mirrors
typeset -A opt_args


_equo_get_mirrors()
{
  mirrors=( ${(f)"$(equo status | grep Repository\ name | cut -d: -f2 | sed 's/^\ *//')"} )
  _describe -t packages 'mirrors' mirrors
}

_equo_get_cmds()
{
  cmds=( ${(f)"$(equo $1 --help |
    sed 's/--multifetch/--multifetch  can be/' |
    sed -r -e '/^(positional|action:)/ {N; d;}' |
    grep -P '^  (?!-h|<package>|{|   )' |
    sed -r 's/^ {2,4}(-*[a-zA-z0-9-]+)(, -\w|)  +(\w.*)/\1:\3/')"} )
  _describe -t commands 'command params' cmds
}

_equo_get_installed_packages()
{
  packages=( ${(f)"$(equo query list installed | sed 's/.*\///')"}  )
  _describe -t packages 'installed packages' packages
}

_equo_get_available_packages()
{
  packages=( ${(f)"$(equo search $1 | grep Package |sed 's/.*\/\([^\ ]*\).*/\1/')"}  )
  _describe -t packages 'available packages' packages
}

_arguments -C \
  "--help[print help]" \
  "--version[print version]" \
  "--color[force colored output]" \
  "--bashcomp[print bash completion script]"\
  '1:command:->cmds' \
  '*:subcommand:->args'

case $state in
  cmds)
    cmds=( ${(f)"$(equo --help |
      grep -P '^  (?!(-h|--color|available))' |
      sed -r 's/^  (\w+)( \[.*\]|)  +(\w.*)/\1:\3/')"} )
    _describe -t commands 'equo command' cmds
  ;;
  args)
    case $line[1] in
      remove|config)
        _equo_get_cmds $line[1] && return 0
        _equo_get_installed_packages
      ;;
      install|i|fetch|download|search|s|source|src|mask|unmask)
        _equo_get_cmds $line[1] && return 0
        _equo_get_available_packages $line[-1]
      ;;
      repo)
        case $line[2] in
          enable|disable|remove|mirrorsort)
            _equo_get_mirrors
          ;;
          add|merge)
          ;;
          *)
            _equo_get_cmds $line[1] 
          ;;
        esac
      ;;
      query|q)
        case $line[2] in
          changelog|revdeps|files|needed|removal|graph|revgraph)
            _equo_get_installed_packages
          ;;
          list)
            case $line[3] in
              available)
                _equo_get_mirrors
              ;;
              installed)
              ;;
              *)
                cmds=( ${(f)"$(equo query list --help |tr "\t" ":" | grep "^::[^:]" | sed 's/^::\([^:\ ]*\)[^:]*:*/\1:/')"} )
                _describe -t commands 'command params' cmds
              ;;
            esac
          ;;
          belongs|description|license|mimetype|asociate|orphans|required|sets|slots|tags)
          ;;
          *)
            _equo_get_cmds $line[1]
          ;;
        esac
      ;;
      notice)
        _equo_get_mirrors
      ;;
      cleanup|status|st|--info|hop)
      ;;
      *)
        _equo_get_cmds $line[1]
      ;;
    esac
  ;;
esac
