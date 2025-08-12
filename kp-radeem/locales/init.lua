Locales = Locales or {}

function _U(key, ...)
    local localeCode = (Config and Config.Locale) or 'en'
    local translations = Locales[localeCode] or {}
    local value = translations[key] or key

    if select('#', ...) > 0 then
        return string.format(value, ...)
    end

    return value
end
