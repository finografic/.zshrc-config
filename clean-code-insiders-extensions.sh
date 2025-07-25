#!/bin/bash
set -e # Exit on error

# 🟢 Core Development Tools
## Essential development tools
# code-insiders --uninstall-extension dbaeumer.vscode-eslint
# code-insiders --uninstall-extension esbenp.prettier-vscode
# code-insiders --uninstall-extension dsznajder.es7-react-js-snippets
# code-insiders --uninstall-extension eamodio.gitlens
# code-insiders --uninstall-extension github.copilot
# code-insiders --uninstall-extension github.copilot-chat
# code-insiders --uninstall-extension ms-playwright.playwright
# code-insiders --uninstall-extension orta.vscode-jest

## Microsoft/Azure Tools
# code-insiders --uninstall-extension github.vscode-pull-request-github
# code-insiders --uninstall-extension ms-azuretools.vscode-azureresourcegroups
code-insiders --uninstall-extension ms-azuretools.vscode-docker
# code-insiders --uninstall-extension ms-azuretools.vscode-azureappservice
# code-insiders --uninstall-extension github.vscode-github-actions

## TypeScript/JavaScript Tools
# code-insiders --uninstall-extension yoavbls.pretty-ts-errors
# code-insiders --uninstall-extension christian-kohler.npm-intellisense
# code-insiders --uninstall-extension styled-components.vscode-styled-components

## Quality of Life Tools
# code-insiders --uninstall-extension aaron-bond.better-comments
# code-insiders --uninstall-extension usernamehw.errorlens
# code-insiders --uninstall-extension editorconfig.editorconfig
# code-insiders --uninstall-extension streetsidesoftware.code-spell-checker

# 🟡 Consider Removal (Uncommonly Used)

## Duplicate/Overlapping
# code-insiders --uninstall-extension nidu.copy-json-path
code-insiders --uninstall-extension christian-kohler.path-intellisense
code-insiders --uninstall-extension wayou.vscode-todo-highlight

## Situational Use
code-insiders --uninstall-extension docker.docker
code-insiders --uninstall-extension ms-python.black-formatter
code-insiders --uninstall-extension ms-python.debugpy
code-insiders --uninstall-extension ms-python.flake8
code-insiders --uninstall-extension ms-python.python
code-insiders --uninstall-extension ms-python.vscode-pylance
code-insiders --uninstall-extension zoellner.openapi-preview
code-insiders --uninstall-extension wallabyjs.wallaby-vscode
code-insiders --uninstall-extension wallabyjs.wallaby-extension-pack
code-insiders --uninstall-extension wallabyjs.quokka-vscode

## Alternative Available
# code-insiders --uninstall-extension formulahendry.auto-rename-tag
code-insiders --uninstall-extension akhaled.key-bindings-to-md
# code-insiders --uninstall-extension anthonyattard.zoomer

# 🔴 Probably Not Required

## Duplicates
code-insiders --uninstall-extension electreefrying.auto-import
code-insiders --uninstall-extension pmneo.tsimporter
code-insiders --uninstall-extension steoates.autoimport
code-insiders --uninstall-extension markis.code-coverage

## Deprecated/Less Maintained
# code-insiders --uninstall-extension mohsen1.prettify-json
code-insiders --uninstall-extension xadillax.viml
code-insiders --uninstall-extension doc-extentions.doctis

## Theme-related
code-insiders --uninstall-extension liviuschera.noctis
# code-insiders --uninstall-extension zurassic.monokai-slate
code-insiders --uninstall-extension zylve.noctis-italicized

## Redundant Functionality
code-insiders --uninstall-extension hyrious.import-cost
code-insiders --uninstall-extension chintans98.markdown-jira
code-insiders --uninstall-extension transnano.markdown-jira-preview
code-insiders --uninstall-extension mblode.pretty-formatter
code-insiders --uninstall-extension shd101wyy.markdown-preview-enhanced
