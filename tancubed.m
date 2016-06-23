function ds = tancubed(categSep,Scale,OptimalForget,maxIncrement)

ds_temp = Scale * tan(((categSep- OptimalForget)*pi/2).^3);
ds = min([abs(maxIncrement) abs(ds_temp)]) * sign(ds_temp);
end