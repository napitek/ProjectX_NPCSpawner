$(function () {

    let modelSelect = $('#modelSelect');
    let scenariosSelect = $('#scenariosSelect');
    let weaponsSelect = $('#weaponsSelect');
    let walkCheckBox = $('#walkCheckBox');

    display(false)

    window.addEventListener('message', function (event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
    });

    modelSelect.change(function () {
        //pedImage.src = "https://docs.fivem.net/peds/" + $(this).val() + ".webp";
        if (modelSelect.val().startsWith('a_c_')) {
            weaponsSelect.attr("disabled", true);
            scenariosSelect.attr("disabled", true);
        } else {
            weaponsSelect.removeAttr('disabled');
            scenariosSelect.removeAttr('disabled');
        }
    });

    weaponsSelect.change(function () {
        //weaponImage.src = "https://docs.fivem.net/peds/" + $(this).val() + ".webp";
    });

    // scenario disabled by checked walk    
    walkCheckBox.change(function () {
        if (walkCheckBox.is(':checked')) {
            scenariosSelect.attr("disabled", true);
        } else {
            scenariosSelect.removeAttr('disabled');
        }
    });

    // ESC Handling
    document.onkeyup = function (data) {
        if (data.which == 27) {
            clearElements();
            $.post('https://Projectx_NPCSpawner/exit', JSON.stringify({}));
            return
        }
    };

    // Close Button
    $("#close").click(function () {
        clearElements();
        $.post('https://Projectx_NPCSpawner/exit', JSON.stringify({}));
        return
    });

    // Add row by #insertRow button click
    $("#insertRow").on("click", function (event) {
        event.preventDefault();

        var newRow = $("<tr>");
        var cols = '';

        //TODO: Write only once
        let pedsNumber = document.getElementById('pedsNumberInput').value;
        let pedModel = document.getElementById('modelSelect').value;
        let pedScenario = document.getElementById('scenariosSelect').value;
        let pedWeapon = document.getElementById('weaponsSelect').value;
        let pedMaxHealth = document.getElementById('maxHealthOption').value;
        let pedArmour = document.getElementById('armourOption').value;
        let pedAccuracy = document.getElementById('accuracyOption').value;
        let pedWalk = document.getElementById('walkCheckBox').checked;
        let teamsRadios = document.getElementsByName('teamsRadio');

        let selectedTeam = 'allies';

        if (pedModel == null || pedModel == '') pedModel = 'a_f_m_beach_01'; //TODO: change pedModel fallback
        if (pedWeapon == null || pedWeapon == '' || pedModel.startsWith('a_c_')) pedWeapon = 'nope';

        if (pedScenario == null || pedScenario == '') {
            if (pedModel.startsWith('a_c_')) {
                pedScenario = 'nope';
            } else if(pedWalk) {
                pedScenario = 'walking';
            } else {
                pedScenario = 'WORLD_HUMAN_SMOKING';
            }
        }

        for (var i = 0, length = teamsRadios.length; i < length; i++) {
            if (teamsRadios[1].checked) {
                selectedTeam = 'enemies';
                break // only one radio can be logically checked;
            }
        }

        //If Model is a Cutscene Model pedsNumber must be only one
        if (pedModel.startsWith('cs')) pedsNumber = 1;

        // Table columns
        cols += '<td><p>' + pedsNumber + '</td>';
        cols += '<td><p>' + pedModel + '</td>';
        cols += '<td><p>' + pedWeapon + '</td>';
        cols += '<td><p>' + pedWalk + '</td>';
        cols += '<td><p>' + pedScenario + '</td>';
        cols += '<td><p>' + pedMaxHealth + '</td>';
        cols += '<td><p>' + pedArmour + '</td>';
        cols += '<td><p>' + pedAccuracy + '</td>';
        cols += '<td><p>' + selectedTeam + '</td>';
        cols += '<td><button class="btn btn-secondary" id ="deleteRow"><i class="fa fa-trash"></i></button</td>';

        // Insert the columns inside a row
        newRow.append(cols);
        // Insert the row inside a table
        $("table").append(newRow);

        //TODO: Please a better add Row (equal row matching)
    });

    // Show modal 
    $("table").on("click", "#showImage", function (event) {

    });

    // Remove row when delete btn is clicked
    $("table").on("click", "#deleteRow", function (event) {
        $(this).closest("tr").remove();
    });

    // Reset Peds Table
    $("#resetTable").click(function () {
        clearElements();
        //wait 1 second for dropdown refill
        setTimeout(function () {
            fillDropdown();
        }, 1000);

    });

    // Spawn Peds
    $("#spawn").click(function () {
        let table = $('#pedsTable').tableToJSON();
        if (table.length > 0) {
            //console.log(JSON.stringify(table));
            //clearElements();
            $.post('https://Projectx_NPCSpawner/spawn', JSON.stringify({
                peds: table,
            }));
            return
        } else {
            console.log('Not PEDS to Spawn');
        }
    });

    function display(bool) {
        if (bool) {
            $("#app").show();
            fillDropdown();
        } else {
            $("#app").hide();
        }
    }

    function clearElements() {
        modelSelect.empty();
        weaponsSelect.empty();
        scenariosSelect.empty();
        $("tbody").children().remove();
    }

    //This function fills the Dropdowns of PED and WEAPONS from data.json file
    function fillDropdown() {

        modelSelect.empty();
        modelSelect.append('<option selected="true" disabled></option>');
        modelSelect.prop('selectedIndex', 0);

        weaponsSelect.empty();
        weaponsSelect.append('<option selected="true" disabled></option>');
        weaponsSelect.prop('selectedIndex', 0);

        scenariosSelect.empty();
        scenariosSelect.append('<option selected="true" disabled></option>');
        scenariosSelect.prop('selectedIndex', 0);

        $.getJSON("data.json", function (data) {
            $.each(data.peds, function (pedKey, pedValue) {
                //console.log(pedValue);
                modelSelect.append($('<option></option>').text(pedValue).attr('value', pedValue));
            });
            new TomSelect("#modelSelect",{
                create: true,
            });
            $.each(data.weapons, function (weaponKey, weaponValue) {
                //console.log(weaponValue);
                weaponsSelect.append($('<option></option>').text(weaponValue.desc).attr('value', weaponValue.hashkey));
            });
            new TomSelect("#weaponsSelect",{
                create: true,
            });
            $.each(data.scenarios, function (scenarioKey, scenarioValue) {
                //console.log(pedValue);
                scenariosSelect.append($('<option></option>').text(scenarioValue).attr('value', scenarioValue));
            });
            new TomSelect("#scenariosSelect",{
                create: true,
            });
        });
        
        
    }

    function startsWith(str, word) {
        return str.lastIndexOf(word, 0) === 0;
    }
})