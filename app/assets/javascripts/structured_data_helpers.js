// Clears dropdowns
function clearDropdowns(dropdown_ids) {
  var dropdown_id;
  for (dropdown_id of dropdown_ids) {
    $('#' + dropdown_id).find("option:gt(0)").remove();
  }
}

// Clears inputs
function clearInputs(input_ids) {
  var input_id;
  for (input_id of input_ids) {
    $('#' + input_id).val('');
  }
}

// Disables inputs
function disableInputs(input_ids) {
  var input_id;
  for (input_id of input_ids) {
    $('#' + input_id).prop('disabled', true);
  }
}

// Enables inputs
function enableInputs(input_ids) {
  var input_id;
  for (input_id of input_ids) {
    $('#' + input_id).prop('disabled', false);
  }
}

// Adds options to dropdown
function addOptions(dropdown_id, data) {
  var option = '';
  for (var i = 0; i < data.length; i++){
    option += '<option value="'+ data[i] + '">' + data[i] + '</option>';
  }
  $('#' + dropdown_id).append(option);
}

function enableSelect2ForDropdowns(dropdown_ids) {
  var dropdown_id;
  for (dropdown_id of dropdown_ids) {
    $('#' + dropdown_id).select2({
      theme: "bootstrap"
    });
  }
}