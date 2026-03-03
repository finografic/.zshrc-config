#!/bin/bash
set -e # Exit on error

# 🟢 Already Tagged as Keep (Just for Reference - DO NOT UNCOMMENT)
## These are listed just to show what we're intentionally keeping
# dbaeumer.vscode-eslint, esbenp.prettier-vscode, dsznajder.es7-react-js-snippets
# eamodio.gitlens, github.copilot*, ms-playwright.playwright, orta.vscode-jest
# github.vscode-*, ms-azuretools.*, styled-components.vscode-styled-components
# aaron-bond.better-comments, usernamehw.errorlens, editorconfig.editorconfig
# streetsidesoftware.code-spell-checker, yoavbls.pretty-ts-errors
# christian-kohler.npm-intellisense

# 🟡 Consider Removal (Uncommonly Used)
## API/Swagger Related (Consider consolidating)
code-insiders --uninstall-extension 42crunch.vscode-openapi --force
code-insiders --uninstall-extension arjun.swagger-viewer --force
code-insiders --uninstall-extension mermade.openapi-lint --force
code-insiders --uninstall-extension mimarec.swagger-doc-viewer --force

## Cucumber/Testing (If not actively using)
code-insiders --uninstall-extension alexkrechik.cucumberautocomplete --force
code-insiders --uninstall-extension connorshea.vscode-test-explorer-status-bar --force
code-insiders --uninstall-extension hbenl.vscode-test-explorer --force
code-insiders --uninstall-extension vespa-dev-works.jestrunit --force

## Formatting/Highlighting (Consider consolidating)
code-insiders --uninstall-extension cliffordfajardo.highlight-line-vscode --force
code-insiders --uninstall-extension foxundermoon.shell-format --force
code-insiders --uninstall-extension vincaslt.highlight-matching-tag --force

## JSON Tools (Consider consolidating)
code-insiders --uninstall-extension mrmlnc.vscode-json5 --force
code-insiders --uninstall-extension zainchen.json --force

# 🔴 Probably Not Required
## Duplicate Functionality
code-insiders --uninstall-extension ecmel.vscode-html-css --force
code-insiders --uninstall-extension fabiospampinato.vscode-browser-refresh --force
code-insiders --uninstall-extension herrmannplatz.npm-dependency-links --force
code-insiders --uninstall-extension kevinmcgowan.typescriptimport --force
code-insiders --uninstall-extension kimuson.ts-type-expand --force

## Rarely Used Utilities
code-insiders --uninstall-extension idleberg.applescript --force
code-insiders --uninstall-extension k--kato.docomment --force
code-insiders --uninstall-extension plibither8.remove-comments --force
code-insiders --uninstall-extension ryu1kn.partial-diff --force
code-insiders --uninstall-extension xshrim.txt-syntax --force

## Consider Built-in Alternatives
code-insiders --uninstall-extension ghmcadams.lintlens --force
code-insiders --uninstall-extension ijs.emotionsnippets --force
code-insiders --uninstall-extension tyriar.sort-lines --force
