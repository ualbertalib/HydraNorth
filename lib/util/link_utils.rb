module LinkUtils
    # ddetermines whether or not a string appears to contain any hyperlinks
    # leverages ActionView::Helpers::TextHelper::AUTO_LINK_RE, which is the
    # same regex used by auto_link, for consistency of behavior
    def linkable?(string)
      !!string.match(ActionView::Helpers::TextHelper::AUTO_LINK_RE)
    end
end
