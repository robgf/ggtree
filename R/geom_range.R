##' bar of range (HPD, range etc) to present uncertainty of evolutionary inference
##'
##'
##' @title geom_range
##' @param range range, e.g. "height_0.95_HPD"
##' @param branch.length corresponding branch.length
##' @param ... additional parameter, e.g. color, size, alpha
##' @return ggplot layer
##' @importFrom ggplot2 aes_string
##' @export
##' @author Guangchuang Yu
geom_range <- function(range = "length_0.95_HPD", branch.length = "branch.length", ...) {
    position = "identity"
    show.legend = NA
    na.rm = TRUE
    inherit.aes = FALSE

    default_aes <- aes_(x=~x, y=~y, xend=~x, yend=~y)

    lower <- paste0('range_lower(', range, ')')
    upper <- paste0('range_upper(', range, ')')

    mapping <- modifyList(default_aes, aes_string(branch.length=branch.length, lower=lower, upper=upper))

    layer(
        stat = StatRange,
        mapping = mapping,
        data = NULL,
        geom = GeomSegment,
        position = position,
        show.legend=show.legend,
        inherit.aes = inherit.aes,
        params = list(na.rm = na.rm,
                      ...),
        check.aes = FALSE
    )

}

StatRange <- ggproto("StatRange", Stat,
                     compute_group = function(self, data, scales, params) {
                         df <- data[!is.na(data[["lower"]]),]
                         df[["lower"]] <- df[["lower"]] + df[["x"]] - df[["branch.length"]]
                         df[["upper"]] <- df[["upper"]] + df[["x"]] - df[["branch.length"]]

                         data.frame(x = df[["lower"]],
                                    xend = df[["upper"]],
                                    y = df[["y"]],
                                    yend = df[["y"]])
                     },
                     required_aes = c("x", "y", "xend", "yend")
                     )


range_lower <- function(range) {
    sapply(range, function(x) as.numeric(x[1]))
}

range_upper <- function(range) {
    sapply(range, function(x) {
        if (length(x) == 1 && is.na(x))
            return(NA)
        as.numeric(x[2])
    })
}

