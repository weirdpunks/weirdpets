pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

// Tamagotchi NFT contract
contract WeirdPets is ERC721 {
    uint256 lifespan;

    // Enum for WeirdPet species
    enum Species {
        Dragon,
        Cat,
        Dog,
        Bear,
        Alien
    }

    // Enum for WeirdPet mood
    enum Mood {
        Happy,
        Neutral,
        Sad
    }

    // Enum for WeirdPet actions
    enum Action {
        Feed,
        Dress,
        Bathe,
        Upgrade
    }

    enum WeaponTypes {
        none,
        sword,
        bow,
        staff,
        knife,
        axe
    }

    enum ArmorTypes {
        none,
        plate,
        leather,
        chain,
        cloth,
        shields
    }

    struct SpeciesAttributes {
        uint8 strength;
        uint8 intelligence;
        uint8 endurance;
        uint8 speed;
        uint8 agility;
    }

    struct SpeciesStats {
        uint256 age;
        uint8 hunger;
        uint8 hygiene;
        uint8 happiness;
    }

    // Struct for WeirdPet NFTs
    struct WeirdPetsData {
        uint256 id;
        address owner;
        Species species;
        Mood mood;
        SpeciesAttributes attributes;
        SpeciesStats stats;
        WeaponTypes weapons;
        ArmorTypes armor;
        bool isEquipped;
        bool isAlive;
    }

    struct LifeSpan {
        Species species;
        uint256 lifeSpan;
    }

    // Mapping from WeirdPet ID to WeirdPet data
    mapping(uint256 => WeirdPetsData) public WeirdPets;
    mapping(uint256 => WeirdPetsData) public onSaleWeirdPets;
    mapping(uint256 => uint256) public WeirdPetPrices;
    mapping(address => uint256) public WeirdPetOwners;
    // Array of all WeirdPet IDs
    uint256[] public WeirdPetIds;
    //LifeSpan[] public lifeSpans;
    uint256[] onSalePets;

    constructor() ERC721("Petz", "WEIRDOS") {
        address contractOwner = msg.sender;
    }

    // Event for when a WeirdPet is created
    event WeirdPetCreated(
        uint256 id,
        address owner,
        Species species,
        bool isAlive
    );

    // Event for when a WeirdPet is sold
    event WeirdPetSold(uint256 id, address previousOwner, address newOwner);

    // Function to create a new WeirdPet
    function createWeirdPet() public {
        uint256 tokenId = 1;
        uint256 id = tokenId;

        Species species;
        uint256 randomNum = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, id))
        ) % 5;
        if (randomNum == 0) {
            species = Species.Dragon;
        } else if (randomNum == 1) {
            species = Species.Cat;
        } else if (randomNum == 2) {
            species = Species.Dog;
        } else if (randomNum == 3) {
            species = Species.Bear;
        } else {
            species = Species.Alien;
        }

        WeirdPetsData memory NewWeirdPet = WeirdPetsData({
            id: id,
            owner: msg.sender,
            species: species,
            mood: Mood.Neutral,
            attributes: SpeciesAttributes({
                strength: 50,
                intelligence: 50,
                endurance: 50,
                speed: 50,
                agility: 50
            }),
            stats: SpeciesStats({
                age: 0,
                hunger: 50,
                hygiene: 50,
                happiness: 50
            }),
            weapons: WeaponTypes.none,
            armor: ArmorTypes.none,
            isEquipped: false,
            isAlive: true
        });

        WeirdPets[id] = NewWeirdPet;
        _safeMint(msg.sender, id++);
        WeirdPetIds.push(id);
    }

    /**
     * Function to feed a WeirdPet
     *
     * @dev Only the owner of the WeirdPet can feed it.
     * @param id The ID of the WeirdPet to feed.
     */
    function feedWeirdPet(uint256 id) public {
        // Ensure that the caller is the owner of the WeirdPet
        require(msg.sender == WeirdPets[id].owner);

        // Ensure that the WeirdPet is alive
        require(WeirdPets[id].isAlive);

        // Increment the WeirdPet's hunger and happiness, and decrement its hygiene
        uint256 hunger = WeirdPets[id].stats.hunger;
        uint256 happiness = WeirdPets[id].stats.happiness;
        uint256 hygiene = WeirdPets[id].stats.hygiene;

        hunger -= 10;
        happiness += 5;
        hygiene += 5;

        // Increment the WeirdPet's age
        incrementAge(id, 10);
    }

    /**
     * Function to dress a WeirdPet
     *
     * @dev Only the owner of the WeirdPet can dress it.
     * @param id The ID of the WeirdPet to dress.
     * @param weaponType The ID of the weapon to equip.
     * @param armorType The ID of the armor to equip.
     */
    function equipWeirdPet(
        uint256 id,
        uint256 weaponType,
        uint256 armorType
    ) public {
        // Ensure that the caller is the owner of the WeirdPet
        require(msg.sender == WeirdPets[id].owner);
        // Ensure that the WeirdPet is alive
        require(WeirdPets[id].isAlive);

        // Equip the WeirdPet with the specified weapon and armor
        WeirdPets[id].isEquipped = true;

        if (weaponType == 1) {
            WeirdPets[id].weapons = WeaponTypes.sword;
        } else if (weaponType == 2) {
            WeirdPets[id].weapons = WeaponTypes.bow;
        } else if (weaponType == 3) {
            WeirdPets[id].weapons = WeaponTypes.staff;
        } else if (weaponType == 4) {
            WeirdPets[id].weapons = WeaponTypes.knife;
        } else {
            WeirdPets[id].weapons = WeaponTypes.axe;
        }

        if (armorType == 1) {
            WeirdPets[id].armor = ArmorTypes.cloth;
        } else if (armorType == 2) {
            WeirdPets[id].armor = ArmorTypes.leather;
        } else if (armorType == 3) {
            WeirdPets[id].armor = ArmorTypes.chain;
        } else if (armorType == 4) {
            WeirdPets[id].armor = ArmorTypes.plate;
        } else {
            WeirdPets[id].armor = ArmorTypes.shields;
        }

        // Increment the WeirdPet's happiness
        uint256 happiness = WeirdPets[id].stats.happiness;

        happiness += 10;

        // Increment the WeirdPet's age
        incrementAge(id, 10);
    }

    /**
     * Function to bathe a WeirdPet
     *
     * @dev Only the owner of the WeirdPet can bathe it.
     * @param id The ID of the WeirdPet to bathe.
     */
    function batheWeirdPet(uint256 id) public {
        // Ensure that the caller is the owner of the WeirdPet
        require(msg.sender == WeirdPets[id].owner);

        // Ensure that the WeirdPet is alive
        require(WeirdPets[id].isAlive);

        // Increment the tamagotchi's hygiene and happiness, and decrement its hunger

        uint256 hunger = WeirdPets[id].stats.hunger;
        uint256 happiness = WeirdPets[id].stats.happiness;
        uint256 hygiene = WeirdPets[id].stats.hygiene;

        hygiene += 10;
        happiness += 5;
        hunger += 10;

        // Increment the WeirdPet's age
        incrementAge(id, 10);
    }

    /**
     * Function to upgrade a WeirdPet
     *
     * @dev Only the owner of the WeirdPet can upgrade it.
     * @param id The ID of the WeirdPet to upgrade.
     * @param attribute The attribute to upgrade.
     */
    function upgradeWeirdPet(uint256 id, uint8 attribute) public payable {
        require(msg.value == 0.001 ether, "Incorrect amount paid");

        // Ensure that the caller is the owner of the WeirdPet
        require(msg.sender == WeirdPets[id].owner);

        // Ensure that the WeirdPet is alive
        require(WeirdPets[id].isAlive);
        // Upgrade the specified attribute of the WeirdPet
        if (attribute == 1) {
            WeirdPets[id].attributes.strength++;
        } else if (attribute == 2) {
            WeirdPets[id].attributes.intelligence++;
        } else if (attribute == 3) {
            WeirdPets[id].attributes.endurance++;
        } else if (attribute == 4) {
            WeirdPets[id].attributes.speed++;
        } else if (attribute == 5) {
            WeirdPets[id].attributes.agility++;
        }

        // Increment the tamagotchi's age
        incrementAge(id, 10);
    }

    /**
     * Function to increment a WeirdPet's age
     *
     * @param id The ID of the WeirdPet to increment the age of.
     * @param increment The number of units to increment the age by.
     */
    function incrementAge(uint256 id, uint256 increment) private {
        // Increment the WeirdPet's age
        uint256 age = WeirdPets[id].stats.age;
        age += increment;

        // If the WeirdPet's age exceeds its lifespan, kill it
        if (WeirdPets[id].stats.age > 100) {
            WeirdPets[id].isAlive = false;
        }
    }

    function tradeWeirdPet(
        uint256 id1,
        uint256 id2,
        address owner1,
        address owner2
    ) public {
        // Ensure that the caller is the owner of WeirdPet 1
        require(msg.sender == owner1);

        // Ensure that tamagotchi 1 is owned by owner1
        require(WeirdPets[id1].owner == owner1);

        // Ensure that WeirdPet 2 is owned by owner2
        require(WeirdPets[id2].owner == owner2);

        // Swap the ownership of WeirdPets
        WeirdPets[id1].owner = owner2;
        WeirdPets[id2].owner = owner1;

        // Transfer WeirdPet 1 to owner2 and WeirdPet 2 to owner1
        _transfer(owner1, owner2, id1);
        _transfer(owner2, owner1, id2);

        // Emit the WeirdPetiSold event for both WeirdPets
        emit WeirdPetSold(id1, owner1, owner2);
        emit WeirdPetSold(id2, owner2, owner1);
    }

    function listForSale(uint256 id, uint256 price) public {
        // Ensure that the caller is the owner of the WeirdPet
        require(msg.sender == WeirdPets[id].owner);

        // Ensure that the WeirdPet is alive
        require(WeirdPets[id].isAlive);

        // Add the WeirdPet to the onSaleWeirdPets mapping
        onSaleWeirdPets[id] = WeirdPets[id];

        // Store the sale price in the WeirdPet data
        WeirdPetPrices[id] = price;
    }

    // Allow users to list WeirdPets for sale
    function listWeirdPetForSale(uint256 id, uint256 salePrice) public {
        // Ensure that the caller is the owner of the WeirdPets
        require(WeirdPets[id].owner == msg.sender);

        // Ensure that the WeirdPet is alive
        require(WeirdPets[id].isAlive == true);

        // Add the WeirdPet to the onSaleWeirdPets mapping
        onSalePets.push(id);
        onSaleWeirdPets[id] = WeirdPets[id];
        WeirdPetPrices[id] = salePrice;
    }

    // Allow users to view the list of available WeirdPets
    function getAllOnSaleWeirdPets() public view returns (uint256[] memory) {
        uint256[] memory onSaleIds = new uint256[](onSalePets.length);
        uint256 index = 0;
        for (uint256 id = 0; id < onSalePets.length; id++) {
            if (onSalePets[id] != 0) {
                onSaleIds[index] = id;
                index++;
            }
        }
        return onSaleIds;
    }

    // Allow users to purchase WeirdPets
    function buyWeirdPet(uint256 id) public payable {
        // Ensure that the WeirdPets is on sale
        require(onSalePets[id] != 0);

        // Get the sale price of the WeirdPet
        uint256 price = onSalePets[id];

        // Ensure that the caller has enough ether to make the purchase
        require(msg.value >= price);

        // Get the current owner and sale owner of the WeirdPet
        address currentOwner = WeirdPets[id].owner;
        address saleOwner = onSaleWeirdPets[id].owner;

        // Transfer the WeirdPet to the caller and transfer the sale price to the seller
        _transfer(saleOwner, msg.sender, id);
        payable(msg.sender).transfer(price);

        // Remove the WeirdPet from the onSaleWeirdPets mapping
        delete onSaleWeirdPets[id];

        // Emit the WeirdPetSold event
        emit WeirdPetSold(id, currentOwner, msg.sender);
    }
}
