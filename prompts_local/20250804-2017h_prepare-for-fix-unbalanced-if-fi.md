# Preparation Prompt: Fix Unbalanced If/Fi Blocks and Complete Bash Migration

**Session Date:** August 4, 2025, 20:17  
**Next Session Goal:** Fix unbalanced if/fi blocks and complete Bash migration with --exclude feature

## Project Context

The `dir-time-downdate` tool recursively updates directory timestamps to match their newest content files. This session continues work on:

1. **Bash Migration:** Converting the script from Zsh to Bash for broader compatibility
2. **Exclude Feature:** Adding `--exclude`/`-e` option to skip directories like `.conda_env`, `.venv`
3. **Block Structure Repair:** Fixing unbalanced if/fi blocks causing syntax errors

## Current Situation

### ✅ **What's Working**
- Core functionality logic is sound
- Exclude feature design is implemented and tested
- Bash compatibility changes identified and partially applied
- Comprehensive debugging approach established

### ❌ **What's Broken**
- Script has unbalanced if/fi and for/done blocks
- Syntax error: "syntax error near unexpected token `fi`"
- Cannot run due to block structure mismatches
- Error line numbers shift when attempting fixes

### 📊 **Key Files to Review**
- `bin/dir-time-downdate` - Main script (currently broken)
- `history/20250804-2017h_debug-bash-migration-and-exclude-feature.md` - Session summary
- Last committed version (Zsh, working) available via `git show HEAD:bin/dir-time-downdate`

## Recommended Approach

### Phase 1: Clean Slate Restoration
```bash
# Start from known-good state
git checkout HEAD -- bin/dir-time-downdate

# Verify it works in original Zsh form
./bin/dir-time-downdate --help
```

### Phase 2: Incremental Bash Migration (Test After Each)
```bash
# 1. Change shebang only
# Edit: #!/usr/bin/env zsh → #!/usr/bin/env bash
# Test: bash -n bin/dir-time-downdate

# 2. Remove local declarations outside functions
# Target: Main Processing Loop section (lines ~370-450)
# Test: bash -n bin/dir-time-downdate

# 3. Fix Zsh-specific parameter expansion
# Target: check_for_version_mismatch function
# Replace: ${(%):-%x} with Bash-compatible logic
# Test: bash -n bin/dir-time-downdate

# 4. Add EXCLUDE_PATTERNS=() variable
# Test: bash -n bin/dir-time-downdate
```

### Phase 3: Add Exclude Feature (Test After Each)
```bash
# 1. Add --exclude argument parsing
# Target: while [[ $# -gt 0 ]] loop
# Test: bash -n bin/dir-time-downdate

# 2. Add exclude logic to main processing loop
# Target: for dir in "$@" loop
# Use proven prune-based approach
# Test: bash -n bin/dir-time-downdate

# 3. Test functionality
# Command: ./bin/dir-time-downdate --exclude .conda_env --exclude .venv --dry-run .
```

## Technical Considerations

### Block Structure Debugging
- Use `bash -n` after every single change
- Count blocks: `awk '/\bif\b/{c++}/\bfi\b/{c--}END{print c}' bin/dir-time-downdate`
- If count ≠ 0, stop and debug before proceeding

### Exclude Logic Architecture
```bash
# Proven working pattern:
for dir in "$@"; do
    # Build prune arguments
    prune_args=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        norm_pattern="${pattern#./}"
        prune_args+=( -name "$norm_pattern" -prune -o )
    done
    
    # Collect directories (avoiding -depth with -prune)
    all_dirs=()
    while IFS= read -r directory; do
        all_dirs+=("$directory")
    done < <(find "$dir" \( -name ".git" -prune -o ${prune_args[@]} -type d -print \))
    
    # Process in post-order
    for (( idx=${#all_dirs[@]}-1 ; idx>=0 ; idx-- )); do
        # ... existing processing logic
    done
done
```

### Critical Success Factors
1. **Never skip syntax checking** - `bash -n` after every edit
2. **One change at a time** - Don't combine edits
3. **Test with real command** - Use actual exclude patterns when working
4. **Preserve working logic** - Don't change core timestamp logic

## Previous Session Insights

### What Caused Problems
- Applying multiple changes simultaneously
- Complex nested loop refactoring without careful block tracking
- Mixing Zsh-to-Bash migration with feature addition

### What Worked Well
- Systematic debugging with automated tools
- Identifying specific Zsh incompatibilities
- Understanding of find -prune behavior

### Key Commands for Validation
```bash
# Syntax check
bash -n bin/dir-time-downdate

# Block count validation
awk '/\bif\b/{c++}/\bfi\b/{c--}END{print c}' bin/dir-time-downdate
awk '/\bfor\b/{c++}/\bdone\b/{c--}END{print c}' bin/dir-time-downdate

# Functional test
./bin/dir-time-downdate --exclude .conda_env --exclude .venv --dry-run .
```

## Success Criteria

### Immediate Goals
- [ ] Script passes `bash -n` syntax check
- [ ] All if/fi and for/done blocks balanced
- [ ] Script runs without syntax errors

### Feature Goals  
- [ ] `--exclude` option recognized and parsed
- [ ] Excluded directories (.conda_env, .venv) not processed
- [ ] No processing messages for files within excluded dirs
- [ ] Dry-run shows only non-excluded directory updates

### Final Validation
- [ ] Test with real project containing .conda_env and .venv
- [ ] Verify timestamp logic still works correctly
- [ ] Confirm symlink-preserving behavior maintained

## Integration Points

This work integrates with:
- Existing template management system
- Configuration hierarchy (XDG Base Directory)
- Version mismatch checking
- Help text and man page documentation

## Next Steps After Success

1. Update man page with exclude option details
2. Add help text for exclude feature
3. Test with various exclude patterns
4. Consider adding exclude patterns to config files
5. Commit all changes with comprehensive commit message

**Remember:** Patience and systematic approach beats rushing. Test after every single change! 