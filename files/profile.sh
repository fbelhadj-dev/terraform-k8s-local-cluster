if [ -n "$BASH_VERSION" ]; then
    PS1='[\u@\H \W]\n> '

    if command -v kubectl >/dev/null 2>&1; then
        alias k='kubectl'
        source <(kubectl completion bash)
        complete -o default -F __start_kubectl k
    fi
fi
