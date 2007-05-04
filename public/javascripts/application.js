// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function addSelected() {
    moveOptions($('select_other_contacts'), $('select_group_contacts'), true);
}

function addAll() {
    moveOptions($('select_other_contacts'), $('select_group_contacts'), false);
}

function removeSelected() {
    moveOptions($('select_group_contacts'), $('select_other_contacts'), true);
}

function removeAll() {
    moveOptions($('select_group_contacts'), $('select_other_contacts'), false);
}

function moveOptions(srcSelect, destSelect, selectedOnly) {
    for (var i = 0; i < srcSelect.options.length; i++) {
        var option = srcSelect.options[i];
        if (selectedOnly == false || option.selected) {
            destSelect.options.add(option);
            i--;
        }
    }
    
}

function selectAllOptions() {
    for (var i = 0; $('select_group_contacts').options.length; i++) {
        $('select_group_contacts').options[i].selected = true;
    }
}