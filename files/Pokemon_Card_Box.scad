$fa = 1;
$fs = 0.4;
sleevedCards = false;
separable = true;
printSeparators = true;
numCards = 400;
cardWidth = 63;
cardHeight = 88;
cardThickness = 0.335;
cardBlockMargin=0.25;
boxMargin=0.5;
wallThickness=1.2;
fingerCutout=30;
numTabs=4;
scaleFactor = 1;
scale([scaleFactor, scaleFactor, scaleFactor])
    storageBox(
        sleevedCards = sleevedCards,
        separable = separable,
        printSeparators = printSeparators,
        numCards = numCards,
        cardWidth = cardWidth,
        cardHeight = cardHeight,
        cardThickness = cardThickness,
        cardBlockMargin = cardBlockMargin,
        boxMargin = boxMargin,
        wallThickness = wallThickness,
        fingerCutout = fingerCutout,
        numTabs = numTabs
    );

// A modular parameterizable card storage box that 
// can include slots for separators
// 
// sleevedCards - Whether you will be storing sleeved cards 
// in this box or not
//
// separable - Whether you want the box to have slots for 
// separators built-in
// 
// printSeparators - Whether you want to print the separators
// or not
//
// numCards - The number of cards you are wanting to store in 
// this deck box
// 
// cardWidth - The width of the cards you are wanting to store
// in this deck box. We automatically add a .5 mm margin so 
// give the exact measurement
// 
// cardHeight - The height of the cards you are wanting to store
// in this deck box. We automatically add a .5 mm margin so 
// give the exact measurement
// 
// cardThickness - The thickness of the cards you are wanting 
// to store in this deck box. We automatically add a .005 
// margin so give as exact a measurement as possible
// 
// cardBlockMargin - How much extra space you want around the
// edges of the recess in the card box
// 
// boxMargin - How much extra space you want around the sides
// of the bottom part of the box to help in allowing the lid
// to slide on smoothly
// 
// wallThickness - How thick you want the walls of your box
// 
// fingerCutout - The diameter of the finger cutout you want
// 
// numTabs - The number of tabs to leave room for on
// your separator (minimum value is 1)
module storageBox(
    sleevedCards = false,
    separable = true,
    printSeparators = false,
    numCards = 100,
    cardWidth = 63,
    cardHeight = 88,
    cardThickness = 0.335,
    cardBlockMargin=0.25,
    boxMargin=0.5,
    wallThickness=1.2,
    fingerCutout=30,
    numTabs=4
    ) {
    cardWidth = cardWidth + 0.5;
    cardHeight = cardHeight + 0.5;
    cardThickness = cardThickness + 0.005;;
    
    // Calculate the card recess (card block) dimensions
    cardBlockWidth = cardWidth + (cardBlockMargin * 2);        
    cardBlockLength = cardThickness * numCards + (cardBlockMargin * 2);
    cardBlockHeight = cardHeight + cardBlockMargin;
        
    // Calculate total box dimensions
    boxWidth = cardBlockWidth + (wallThickness * (separable ? 4: 2));
    boxLength = cardBlockLength + (wallThickness * 2);
    boxHeight = cardBlockHeight + wallThickness;
    
    // Calculate separator distance
    separatorSeparation = cardThickness * 50;
    separatorTabLength = cardBlockHeight / 2;
    

    
    box(
        boxLength,
        boxHeight,
        boxWidth,
        wallThickness,
        separable,
        separatorSeparation,
        separatorTabLength
    );
    translate([cardWidth * -1.25, 0, 0])
        lid(
            boxLength, 
            boxHeight,
            boxWidth,
            wallThickness,
            boxMargin,
            fingerCutout
        );
    if (separable && printSeparators) {
        for (tabNum = [0:1:(numTabs-1)]) {
            sepOffset = tabNum * (wallThickness * 1.05);
            tabHeight = cardHeight * .1;
            translate([ -cardWidth * .75, -wallThickness * numTabs * 1.25 + sepOffset, wallThickness])
                rotate([90, -90, 90])
                separator(wallThickness * .95, cardBlockWidth, cardHeight, wallThickness, separatorTabLength, numTabs, tabNum, tabHeight);
        }
    }
}

module box(
    boxLength,
    boxHeight,
    boxWidth,
    wallThickness,
    separable,
    separatorSeparation,
    separatorTabLength
    ) {
    recessWidth = boxWidth - wallThickness*(separable ? 4: 2);
    recessLength = boxLength - wallThickness*2;
    recessOffsetMultiplier = separable ? 2 : 1;
    difference() {
        // Create base box
        cube([boxWidth, boxLength, boxHeight]);
        
        // Carve out a recess
        translate([wallThickness*recessOffsetMultiplier, wallThickness, wallThickness])
            cube([recessWidth, recessLength, boxHeight]);
        
        // Cut out the separator slots
        if (separable) {
            separatorStart = separatorSeparation + wallThickness;
            separatorEnd = boxLength - separatorSeparation;
            separatorTabCutEnd = boxHeight - separatorTabLength;
            for (dy = [separatorStart: separatorSeparation: separatorEnd] ) {
                translate([wallThickness, dy, separatorTabCutEnd])
                    cube([boxWidth-wallThickness*2, wallThickness, separatorTabLength]);
            }
        }
    }
}

module lid(
    boxLength,
    boxHeight,
    boxWidth,
    wallThickness,
    boxMargin,
    fingerCutout) {
    recessWidth = boxWidth + boxMargin * 2;
    recessLength = boxLength + boxMargin * 2;
    
    lidWidth = recessWidth + wallThickness * 2;
    lidLength = recessLength + wallThickness * 2;
    lidHeight = boxHeight + boxMargin + wallThickness;
    
    difference() {
        // Create initial lid cube
        cube([lidWidth, lidLength, lidHeight]);
        
        // Cut out the lid recess
        translate([wallThickness,wallThickness,wallThickness])
            cube([recessWidth, recessLength, lidHeight]);
        
        // Cut out the finger slots
        translate([
            -boxMargin,
            lidLength/2,
            lidHeight
            ]){
            rotate(a=[0,90,0]){
                cylinder(h=lidLength,d=fingerCutout);
            }
        }
    }
}

module separator(
    thickness, 
    width, 
    height, 
    jointWidth,
    jointHeight,
    numTabs,
    tabNum,
    tabHeight
) 
{
    // Create the bottom portion of the separator
    height = height - tabHeight;
    cube([width, thickness, height]);
    
    // Create the top portion of the separator with the joint
    jointHeight = jointHeight - tabHeight;
    topWidth = width + jointWidth * 2;
    translate([-jointWidth, 0, height - jointHeight]) 
        cube([topWidth, thickness, jointHeight]);
    
    // Create the top tab
    tabDiameter = topWidth / numTabs;
    tabNum = (tabNum >= numTabs / 2) ? tabNum - round(numTabs / 2): tabNum;
    tabOffset = ((2 * tabNum) + 1) * tabDiameter / 2;
    translate([tabOffset - jointWidth, thickness, height])
        rotate([90, 0, 0])
        resize([0, tabHeight * 2, 0])
        cylinder(h = thickness, d = tabDiameter);
}