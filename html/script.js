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
        if (walkCheckBox.prop('checked')) {
            scenariosSelect.attr("disabled", true);
        } else {
            scenariosSelect.removeAttr('disabled');
        }
    });

    // ESC Handling
    document.onkeyup = function (data) {
        if (data.which == 27) {
            //clearElements();
            $.post('https://Projectx_NPCSpawner/exit', JSON.stringify({}));
            return
        }
    };

    // Close Buttons
    $("#close").click(function () {
        //clearElements();
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
        if (pedWeapon == null || pedWeapon == 'nope' || pedModel.startsWith('a_c_')) pedWeapon = 'nope';

        if (pedWalk) {
            pedScenario = 'walking';
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
        cols += '<td id="pedsNumber"><p>' + pedsNumber + '</td>';
        cols += '<td id="pedModel"><p>' + pedModel + '</td>';
        cols += '<td id="pedWeapon"><p>' + pedWeapon + '</td>';
        cols += '<td id="pedWalk"><p>' + pedWalk + '</td>';
        cols += '<td id="pedScenario"><p>' + pedScenario + '</td>';
        cols += '<td id="pedMaxHealth"><p>' + pedMaxHealth + '</td>';
        cols += '<td id="pedArmour"><p>' + pedArmour + '</td>';
        cols += '<td id="pedAccuracy"><p>' + pedAccuracy + '</td>';
        cols += '<td id="selectedTeam"><p>' + selectedTeam + '</td>';
        cols += '<td><button class="btn btn-secondary" id="deleteRow"><i class="fa fa-trash"></i></button</td>';
        cols += '<td><button class="btn btn-fuchsia" id="singleSpawn"><i class="fa fa-fire"></i></button</td>';

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

    // Reset table
    $("#resetTable").click(function () {
        $("tbody").children().remove();
    });

    // Spawn Row Peds
    $("table").on("click", "#singleSpawn", function (event) {
        let teamsRelation = document.getElementById('relationSelect').value;
        let spawnTypeRadios = document.getElementsByName('spawnTypeRadio');
        let row = $(this).closest("tr");
        let quantity = row.find("#pedsNumber").text();
        let model = row.find("#pedModel").text();
        let weapon = row.find("#pedWeapon").text();
        let walk = row.find("#pedWalk").text();
        let scenario = row.find("#pedModel").text();
        let maxHealth = row.find("#pedMaxHealth").text();
        let armour = row.find("#pedArmour").text();
        let accuracy = row.find("#pedAccuracy").text();
        let selectedTeam = row.find("#selectedTeam").text();
        let selectedSpawnType = 'line';

        let json = [];
        json.push({ "Quantity": quantity, "Model": model, "Weapon": weapon, "Walk": walk, "Scenario": scenario, "MaxHealth": maxHealth, "Armour": armour, "Accuracy": accuracy, "Team": selectedTeam });

        $.post('https://Projectx_NPCSpawner/spawn', JSON.stringify({
            peds: json,
            type: selectedSpawnType,
            rel: teamsRelation,
        }));

        row.css("color","#ff4081");
        return
    });

    // Spawn Table Peds
    $("#spawn").click(function () {
        let spawnTypeRadios = document.getElementsByName('spawnTypeRadio');
        let teamsRelation = document.getElementById('relationSelect').value;
        let selectedSpawnType = 'line';

        for (var i = 0, length = spawnTypeRadios.length; i < length; i++) {
            if (spawnTypeRadios[1].checked) {
                selectedSpawnType = 'area';
                break; // only one radio can be logically checked;
            }
        }

        let json = $('#pedsTable').tableToJSON();

        if (json.length > 0) {
            $.post('https://Projectx_NPCSpawner/spawn', JSON.stringify({
                peds: json,
                type: selectedSpawnType,
                rel: teamsRelation,
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

    //This function fills the Dropdowns of PED and WEAPONS from data.json file
    function fillDropdown() {
        $.getJSON("data.json", function (data) {

            $.each(data.peds, function (pedKey, pedValue) {
                //console.log(pedValue);
                modelSelect.append($('<option></option>').text(pedValue).attr('value', pedValue));
            });
            new TomSelect("#modelSelect", {});

            weaponsSelect.append($('<option></option>').text('nope').attr('value', 'nope'));
            $.each(data.weapons, function (weaponKey, weaponValue) {
                //console.log(weaponValue);
                weaponsSelect.append($('<option></option>').text(weaponValue.desc).attr('value', weaponValue.hashkey));
            });
            new TomSelect("#weaponsSelect", {});

            $.each(data.scenarios, function (scenarioKey, scenarioValue) {
                //console.log(pedValue);
                scenariosSelect.append($('<option></option>').text(scenarioValue).attr('value', scenarioValue));
            });
            new TomSelect("#scenariosSelect", {});
        });
    }

    function startsWith(str, word) {
        return str.lastIndexOf(word, 0) === 0;
    }
})