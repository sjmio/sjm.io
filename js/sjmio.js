

$(function ()
{
	var sticky_el = $("#sticky-container");
	
	// only continue if there is a sticky container on the page
	if (sticky_el.length == 0)
		return;
	
	var is_sticky = false;
	var el_offset = sticky_el.offset().top;
	
	$(window).scroll(function ()
	{
		var thresh = $(document).scrollTop() + 24 > el_offset;
		if (!is_sticky && thresh)
		{
			sticky_el.addClass("sticky");
			is_sticky = true;
		} else if (is_sticky && !thresh)
		{
			sticky_el.removeClass("sticky");
			is_sticky = false;
		}
	});
});
