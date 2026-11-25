# cargo-progress.awk --- cargo's progress bar as lines Guix understands.
#
# Reads cargo's standard error.  Cargo, told to draw its bar without a
# terminal (CARGO_TERM_PROGRESS_WHEN=always), redraws it after a carriage
# return:
#
#       Building [=====>          ] 245/1870: serde, zbus, ...\r
#
# Guix draws a progress bar for a build whose log has lines starting with
# "[245/1870]" or "[ 13%]" (guix/status.scm), so each new count becomes one
# such line; everything else passes through unchanged.
#
# In a suite (cargo-suite.scm), CARGO_PROGRESS_PART and CARGO_PROGRESS_PARTS
# say which member this is, and the line gives the whole suite's progress as
# a percentage, so the bar does not start again from zero for each member.

BEGIN {
    RS = "\r\n|\r|\n"
    part = ENVIRON["CARGO_PROGRESS_PART"] + 0
    parts = ENVIRON["CARGO_PROGRESS_PARTS"] + 0
    if (parts < 1 || part < 1 || part > parts) {
        part = 1
        parts = 1
    }
    last = ""
}

match($0, /^ *Building \[[^]]*\] *([0-9]+)\/([0-9]+)/, m) {
    done = m[1] + 0
    total = m[2] + 0
    if (parts == 1) {
        key = done "/" total
        line = sprintf("[%d/%d] compiling crates", done, total)
    } else {
        percent = int(100 * ((part - 1) + (total > 0 ? done / total : 0)) / parts)
        if (percent > 100)
            percent = 100
        key = percent
        line = sprintf("[%3d%%] suite member %d of %d: %d/%d crates",
                       percent, part, parts, done, total)
    }
    if (key != last) {
        print line
        fflush()
        last = key
    }
    next
}

{
    sub(/ +$/, "")
    # A record cut off by a carriage return and empty once trimmed is what
    # is left of an erased bar, not a blank line of cargo's output.
    if ($0 != "" || RT ~ /\n/) {
        print
        fflush()
    }
}
