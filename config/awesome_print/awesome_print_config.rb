# Awesome_print defaults.
# Awesome print only accept a small range of colors for its output. We'll try
# to get colors as close as our theme as we can. When not sure what a color is,
# we'll just put it to red, to easily spot it.
AwesomePrint.defaults = {
  indent:     2,
  index:      true,
  html:       false,
  multiline:  true,
  plain:      false,
  raw:        false,
  sort_keys:  true,
  limit:      false,
  color: {
    args:        :greenish,
    array:       :pale,
    bigdecimal:  :blue,
    class:       :yellow,
    date:        :red,
    falseclass:  :cyanish,
    fixnum:      :blue,
    float:       :blue,
    hash:        :pale,
    keyword:     :green,
    method:      :greenish,
    nilclass:    :cyanish,
    string:      :blueish,
    struct:      :red,
    symbol:      :cyanish,
    time:        :red,
    trueclass:   :cyanish,
    variable:    :green
  }
}
