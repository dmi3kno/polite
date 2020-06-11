is.nameempty <- function(x){
  nx <- names(x)
  if(is.null(nx))
    return(rep(TRUE, length(x)))
  is.na(nx) | nx==""
}

match_to_formals <- function(a, f, keep_passed_names=TRUE){
  l_wo_names <- is.nameempty(a)
  # named arguments only
  a_w_names <- names(a)[!l_wo_names]
  # how many arguments are unnamed
  l_unn <- length(a[l_wo_names])
  # formals, which have not been explicitly referred to in arguments
  nms_f <- names(f)[!names(f) %in% a_w_names]
  # position of dots in unreferred formals, if not found, assumed to be at the end
  dots_pos <- match("...", nms_f, nomatch = length(nms_f)+1)
  # foreign names (names passed to dots) can be suppressed, but it is probably not a good idea
  if(!keep_passed_names){
    a_w_names <- ifelse(a_w_names %in% names(f), a_w_names, "...")
    names(a)[!l_wo_names] <- a_w_names # this part has names so it is matched literally
  }

  names(a)[l_wo_names] <- c(nms_f[seq_len(min(l_unn, dots_pos-1))],             # this part is matched by position
                            rep.int("...", times=max(0,l_unn-dots_pos+1)))  # this part is passed to dots
  a
}
