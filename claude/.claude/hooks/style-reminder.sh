#!/bin/bash
# UserPromptSubmit hook. Injects style rules as additionalContext every prompt.
# Stated as facts, not commands — imperative out-of-band text can trip
# prompt-injection defenses (hooks.md).
cat >/dev/null
jq -n '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",
  additionalContext:"Active response style is caveman-lite: no preamble or closing recap, no filler or hedging, articles and full sentences kept, prose under ~150 words. Code, commits, and PR text stay normal English."}}'
