--!native

@native
local function numberFormat(number: number, formatType: "Comma" | "Short", decimalPlaces: number?): string
	if formatType == "Comma" then
		local formatted = tostring(math.floor(math.abs(number)))
		local result = ""
		local length = #formatted

		for i = length, 1, -1 do
			result = string.sub(formatted, i, i) .. result
			if (length - i + 1) % 3 == 0 and i > 1 then
				result = "," .. result
			end
		end

		if number < 0 then
			result = "-" .. result
		end

		return result
	elseif formatType == "Short" then
		local decimals = decimalPlaces or 2
		local absNumber = math.abs(number)

		if absNumber < 1000 then
			return tostring(math.floor(number * 10 ^ decimals + 0.5) / 10 ^ decimals)
		end

		local suffixes = { "K", "M", "B", "T", "Q" }
		local suffixIndex = 1
		local divisor = 1000

		while absNumber >= divisor * 1000 and suffixIndex < #suffixes do
			divisor = divisor * 1000
			suffixIndex = suffixIndex + 1
		end

		local shortNumber = absNumber / divisor
		local formatted = string.format("%." .. decimals .. "f", shortNumber)

		if decimals > 0 then
			formatted = string.gsub(formatted, "%.?0+$", "")
		end

		local result = formatted .. suffixes[suffixIndex]

		if number < 0 then
			result = "-" .. result
		end

		return result
	end

	return tostring(number)
end

return {
	numberFormat = numberFormat,
}
