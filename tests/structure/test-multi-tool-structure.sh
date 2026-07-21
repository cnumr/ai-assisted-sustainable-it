#!/usr/bin/env bash
# Compatibilité : la structure attendue est désormais mono-outil Sustainable IT.
exec bash "$(dirname "${BASH_SOURCE[0]}")/test-sustainable-it-structure.sh"
