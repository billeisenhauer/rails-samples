$('.toggle').each(function() {
	var $toggle = $(this);
	var $checkboxes = $('.toggle-target');
	$toggle.change(function() {
		if (this.checked) {
			$checkboxes.attr('checked', 'checked');
		} else {
			$checkboxes.removeAttr('checked');
		}
	});
});
