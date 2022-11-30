[
    .[]|
    (
        .formula_names[],.cask_tokens[]
    )
]|
del(.[]|
    select(
        .==(
            "cblecker/tap/hypershift" # head only formula
            "cblecker/tap/kubectl-dev_tool" # head only formula
            "cblecker/tap/ocm-backplane" # internal tool
        )
    )
)
