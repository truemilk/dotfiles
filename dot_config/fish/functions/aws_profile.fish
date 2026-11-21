function aws_profile --description 'Choose the active AWS profile with fzf'
    set -l profile (aws configure list-profiles | fzf --min-height=20+ --prompt 'Choose active AWS profile: ')
    or return
    set -gx AWS_PROFILE $profile
end
