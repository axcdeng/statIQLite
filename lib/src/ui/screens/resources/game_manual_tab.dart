import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:roboscout_iq/src/ui/screens/resources/pdf_viewer_screen.dart';

/// A single game manual rule entry.
class GameRule {
  final String id;
  final String section;
  final String title;
  final String body;
  final List<String> tags;

  const GameRule({
    required this.id,
    required this.section,
    required this.title,
    required this.body,
    this.tags = const [],
  });
}

/// All sections in the game manual, in order of appearance.
const List<String> kManualSections = [
  'S',
  'G',
  'GG',
  'SG',
  'SC',
  'R',
  'RSC',
  'T'
];

const Map<String, String> kSectionNames = {
  'S': 'Safety',
  'G': 'General',
  'GG': 'General Game',
  'SG': 'Specific Game',
  'SC': 'Scoring',
  'R': 'Robot',
  'RSC': 'Robot Skills',
  'T': 'Tournament',
};

/// VEX IQ Robotics Competition Mix & Match 2025-2026
/// Official game manual rules – Version 3.0 (January 29, 2026).
/// Source: Mix-And-Match-3.0.pdf
final List<GameRule> kGameManualRules = [
  // ═══════════════════════════════════════════
  //  S – Safety Rules
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<S1>',
    section: 'S',
    title: 'Safety is the top priority',
    body:
        'If at any time a Robot operation or a Team action is deemed unsafe or dangerous by the Event Partner or any event staff/volunteer, the offending Team may be Disabled and/or Disqualified for the Match at the Head Referee\'s discretion. The Game Design Committee and the REC Foundation place a carefully considered emphasis on the safety of all involved. All rules carry an implicit expectation that the safety of everyone comes first.',
    tags: ['safety', 'disabled', 'disqualified', 'priority'],
  ),
  const GameRule(
    id: '<S2>',
    section: 'S',
    title: 'Follow the REC Foundation Code of Conduct',
    body:
        'All event attendees are required to follow the REC Foundation\'s Code of Conduct.',
    tags: ['safety', 'code of conduct', 'REC Foundation'],
  ),
  const GameRule(
    id: '<S3>',
    section: 'S',
    title: 'Participant release forms',
    body:
        'Each Student Team member must have a completed participant release form on file for the event and season. A Student Team member cannot participate in an event without a completed release form on file.',
    tags: ['safety', 'release form', 'participation'],
  ),

  // ═══════════════════════════════════════════
  //  G – General Rules
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<G1>',
    section: 'G',
    title: 'Treat everyone with respect',
    body:
        'All Teams are expected to conduct themselves in a respectful and professional manner while competing in VEX IQ Robotics Competition events. If a Team or any of its members are disrespectful or uncivil to event staff, volunteers, or fellow competitors, they may be Disqualified from a current or upcoming Match. Repeated or extreme Violations could result in a Team being Disqualified from an entire event.',
    tags: ['respect', 'conduct', 'disqualification'],
  ),
  const GameRule(
    id: '<G2>',
    section: 'G',
    title: 'VIQRC is a student-centered program',
    body:
        'Adults should not make decisions about the Robot\'s build, design, or gameplay, and should not provide an unfair advantage by providing "help" that is beyond the Students\' independent abilities. Students must be prepared to demonstrate an active understanding of their Robot\'s design, construction, and programming to judges or event staff.',
    tags: ['student centered', 'adults', 'mentorship', 'design'],
  ),
  const GameRule(
    id: '<G3>',
    section: 'G',
    title: 'Use common sense',
    body:
        'When reading and applying the various rules in this document, please remember that common sense always applies. If there is no rule prohibiting an action, it is generally legal. Teams will be given the "benefit of the doubt" in the case of accidental or edge-case rules infractions, but there is a limit and repeated or strategic infractions will still be penalized.',
    tags: ['common sense', 'benefit of the doubt', 'interpretation'],
  ),
  const GameRule(
    id: '<G4>',
    section: 'G',
    title: 'All work must represent the skill level of the Students',
    body:
        'The Team\'s design, Robot, coding, strategy, and ongoing work must represent the skill level of the Students currently on the Team. Teams must avoid academic dishonesty and should not copy a Robot or mechanism that has been provided for them. Teams may be inspired by designs by other Teams but are expected to document and demonstrate iteration in their engineering notebook. Unmodified Hero Bots are always legal for use.',
    tags: ['skill level', 'academic dishonesty', 'hero bot', 'iteration'],
  ),
  const GameRule(
    id: '<G5>',
    section: 'G',
    title: 'Each Student can only belong to one Team',
    body:
        'Each Team must include Drive Team Members, Coder(s), Designer(s), and Builder(s). No Student may fulfill any of these roles for more than one VEX IQ Robotics Competition Team in a given competition season. Students may have more than one role on the Team. Team members may only move from one Team to another for non-strategic reasons outside of the Team\'s control.',
    tags: ['one team', 'student roles', 'team membership'],
  ),

  // ═══════════════════════════════════════════
  //  GG – General Game Rules
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<GG1>',
    section: 'GG',
    title: 'Drivers drive your Robot, and stay in the Driver Station',
    body:
        'During a Match, Robots may only be operated by that Team\'s Drivers and/or software running on the Robot\'s control system. Each Team may send up to three (3) Drive Team Members to their Driver Station: two (2) Drivers and one (1) Loader. Drive Team Members must remain in their Driver Station except when legally interacting with their Robot per <GG10>. Individuals who are not Drive Team Members cannot provide directions, commands, or advice during the Match.',
    tags: ['drivers', 'driver station', 'loader', 'drive team'],
  ),
  const GameRule(
    id: '<GG2>',
    section: 'GG',
    title: 'You must participate',
    body:
        'If a Team fails to appear or participate in a Qualification Match, that Team will receive zero (0) Alliance Score. A Team that does not participate in any Qualification Matches cannot be considered for judged awards at that event. A Team may always elect to play a Match even if they are unable to provide a Robot.',
    tags: ['participation', 'qualification', 'no-show', 'awards'],
  ),
  const GameRule(
    id: '<GG3>',
    section: 'GG',
    title: 'Pre-match setup',
    body:
        'At the start of each Match, Drive Team Members must set up their Robot per <SG1> within the time allotted. As a guideline, five seconds to check Robot alignment would be acceptable, but five minutes to assemble multiple parts together would not.',
    tags: ['pre-match', 'setup', 'starting position', 'time limit'],
  ),
  const GameRule(
    id: '<GG4>',
    section: 'GG',
    title: 'Hands out of the Field',
    body:
        'During a Match, Drive Team Members are prohibited from making intentional contact with any Field Element, Robot, or Scoring Object that has been introduced to the Field, except for the allowances in <GG10>, <RSC5>, and/or <SG6>. Drive Team Members are not permitted to reach into the 3-dimensional volume of the Field Perimeter at any time during the Match.',
    tags: ['hands out', 'field contact', 'no touching'],
  ),
  const GameRule(
    id: '<GG5>',
    section: 'GG',
    title: 'Match Replays are allowed, but rare',
    body:
        'Match replays are at the discretion of the Event Partner and Head Referee, and will only be issued in the most extreme circumstances, such as Score Affecting "Field fault" issues (e.g., Scoring Objects not being reset, Field Elements detaching) or Score Affecting game rule issues (e.g., a Field is reset before the score is determined).',
    tags: ['replay', 'field fault', 'extreme circumstances'],
  ),
  const GameRule(
    id: '<GG6>',
    section: 'GG',
    title: 'Disqualifications',
    body:
        'A Team that is issued a Disqualification in a Qualification Match receives zero (0) points. The other Team on their Alliance will still receive points. In Finals Matches, Disqualifications apply to the whole Alliance. A Team that receives a Disqualification in a Robot Skills Match will receive a score of zero (0).',
    tags: ['disqualification', 'zero points', 'finals', 'qualification'],
  ),
  const GameRule(
    id: '<GG7>',
    section: 'GG',
    title: 'Timeouts',
    body: 'There are no timeouts in VIQRC tournaments.',
    tags: ['timeouts', 'none'],
  ),
  const GameRule(
    id: '<GG8>',
    section: 'GG',
    title: 'Keep your Robot together',
    body:
        'Robots may not intentionally detach parts or leave mechanisms on the Field during any Match. Parts that become unintentionally detached from the Robot are no longer considered to be part of the Robot and can be either left on the Field or collected by a Drive Team Member during a Robot reset using <GG10>.',
    tags: ['robot parts', 'detach', 'mechanisms'],
  ),
  const GameRule(
    id: '<GG9>',
    section: 'GG',
    title: 'Don\'t damage the Field',
    body:
        'Robot interactions which damage the Field or any Field Elements are prohibited. "Damage" is defined as anything which requires repair in order to begin the next Match, such as causing part of a Goal to detach from the Field.',
    tags: ['damage', 'field elements', 'repair'],
  ),
  const GameRule(
    id: '<GG10>',
    section: 'GG',
    title: 'Handling the Robot mid-match',
    body:
        'If a Robot goes completely outside the playing Field, gets stuck, tips over, or otherwise requires assistance, the Drive Team Members may retrieve & reset their Robot. They must signal the Referee by placing their VEX IQ Controller on the ground. The Robot must be placed back into a legal position that meets <SG1>. Scoring Objects being controlled by the Robot must be removed from the Field and reintroduced by a Loader per <SG4>.',
    tags: ['mid-match', 'reset', 'stuck', 'retrieve', 'controller down'],
  ),
  const GameRule(
    id: '<GG11>',
    section: 'GG',
    title: 'Drivers switch Controllers midway through the Match',
    body:
        'In a given Match, up to two (2) Drivers may be in the Driver Station per Team. The two Drivers must switch their controller between thirty-five seconds (0:35) and twenty-five seconds (0:25) remaining in the Match. No Driver shall operate a Robot for more than thirty-five (35) seconds. The second Driver may not touch their Team\'s controls until the controller is passed to them.',
    tags: [
      'driver switch',
      'mid-match',
      '35 seconds',
      '25 seconds',
      'controller'
    ],
  ),
  const GameRule(
    id: '<GG12>',
    section: 'GG',
    title: 'End of the Match',
    body:
        'When one minute has elapsed, the Match ends. All Robot motion must cease. Any scoring after the Match timer stops (due to residual Robot motion) will not count. As defined in <SC1>, all scoring statuses are evaluated after the Match and all objects come to rest.',
    tags: ['end of match', 'timer', 'scoring evaluation', 'motion stops'],
  ),
  const GameRule(
    id: '<GG13>',
    section: 'GG',
    title: 'Ending a Match early',
    body:
        'If an Alliance wants to end a Qualification Match or a Finals Match early, both Teams must signal the referee by ceasing all Robot motion and placing their controllers on the ground. The referee will then signal that the Match is over and begin to tally the score.',
    tags: ['early end', 'concede', 'controllers down'],
  ),

  // ═══════════════════════════════════════════
  //  SG – Specific Game Rules
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<SG1>',
    section: 'SG',
    title: 'Starting a Match',
    body:
        'At the beginning of a Match, the Robot must: (a) Fit within 11" wide × 20" long × 15" high. (b) Not be contacting any Goals other than its assigned Triangle Goal, other Robots, or Scoring Objects other than a max of one Preload. (c) Be contacting the structure of one of the two Triangle Goals (Team 1/Red → red Triangle Goal, Team 2/Blue → blue Triangle Goal). (d) Only be contacting the Floor and the Goal structure. (e) Be completely stationary until the Match timer starts (pre-charging pneumatics is the only exception). (f) Match the configuration checked during inspection.',
    tags: [
      'starting position',
      '11 × 20 × 15',
      'triangle goal',
      'pre-match',
      'stationary'
    ],
  ),
  const GameRule(
    id: '<SG2>',
    section: 'SG',
    title: 'Horizontal expansion is limited',
    body:
        'Robots cannot expand horizontally beyond the 11" × 20" starting size limit at any time in the Match.',
    tags: ['expansion', 'horizontal', '11 × 20', 'size limit'],
  ),
  const GameRule(
    id: '<SG3>',
    section: 'SG',
    title: 'Vertical expansion is unlimited',
    body:
        'Once the Match begins, Robots may expand vertically beyond the 15" starting size limit with no limits.',
    tags: ['expansion', 'vertical', 'unlimited', 'height'],
  ),
  const GameRule(
    id: '<SG4>',
    section: 'SG',
    title: 'Keep Scoring Objects in the Field',
    body:
        'Scoring Objects that leave the Field may be reintroduced by a Loader per <SG6>. Blue Pins → blue Load Zone only. Red Pins → red Load Zone only. Orange Pins/Beams → given to the closest Loader. Connected Scoring Objects that leave must be separated and reintroduced one at a time. Intentional or strategic Violations immediately escalate to a Major Violation.',
    tags: ['scoring objects', 'out of field', 'reintroduce', 'load zone'],
  ),
  const GameRule(
    id: '<SG5>',
    section: 'SG',
    title: 'Each Robot gets one Pin as a Preload',
    body:
        'For Teamwork Challenge Matches, Team 1 / Red Team uses a red Pin as their Preload, Team 2 / Blue Team uses a blue Pin. Prior to the start of each Match, each Preload must be: (a) Contacting exactly one Robot. (b) Not contacting any Field Elements (excluding the Floor), Goals, or other Scoring Objects. Preloads are required, not optional.',
    tags: ['preload', 'pin', 'red', 'blue', 'pre-match'],
  ),
  const GameRule(
    id: '<SG6>',
    section: 'SG',
    title: 'Using the Load Zone',
    body:
        'Scoring Objects may be Loaded through the Load Zone during the Match. Red and blue Pins may only be Loaded into the matching Load Zone. The Scoring Object must be placed in contact with the VEX IQ beam attached to the Floor. The Loader may only put a Scoring Object into a Load Zone if no other Scoring Objects are in contact with that Load Zone. A Robot may not contact a Scoring Object in the Load Zone while it is being contacted by a human. Once released, it may no longer be contacted by a Loader.',
    tags: ['load zone', 'loader', 'pin introduction', 'one at a time'],
  ),

  // ═══════════════════════════════════════════
  //  SC – Scoring
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<SC1>',
    section: 'SC',
    title: 'Scoring evaluated after the Match',
    body:
        'All scoring statuses are evaluated after the Match ends, once all Scoring Objects, Field Elements, and Robots on the Field come to rest. Referees should avoid moving Scoring Objects while evaluating. Points scored during a Violation should not be deducted from a score, other than scoring which takes place after the Match due to continued Robot movement.',
    tags: ['scoring', 'evaluation', 'post-match', 'come to rest'],
  ),
  const GameRule(
    id: '<SC2>',
    section: 'SC',
    title: 'Scoring evaluated visually by a Head Referee',
    body:
        'All scoring statuses are evaluated visually by a Head Referee, to the best of their ability. Referees and event staff are not allowed to review any videos or pictures from the Match. If there is a concern regarding the score, only the Drive Team Members from that Match (not an Adult) may share their questions with the Head Referee.',
    tags: ['scoring', 'visual', 'head referee', 'no video review'],
  ),
  const GameRule(
    id: '<SC3>',
    section: 'SC',
    title: 'Connected Scoring Objects form a Stack',
    body:
        'A Scoring Object can be Connected to another to form a Stack. The Stack must be roughly vertical and cannot be in contact with a Robot. A Pin is Connected if it is fully nested with another Scoring Object and neither the Pin nor the Stack is touching a Robot. A Beam is Connected if it is fully nested to one or more Connected Pins and/or the Standoff Goal and is not touching a Robot. A Beam cannot be Connected to another Beam. A Beam may be Connected to up to three (3) Pins simultaneously; each Pin Connected directly to a Beam is part of a separate Stack. Robot contact with a lower Stack in a multi-Stack structure has no impact on higher Stacks.',
    tags: ['connected', 'stack', 'nested', 'vertical', 'beam', 'pin'],
  ),
  const GameRule(
    id: '<SC4>',
    section: 'SC',
    title: 'Color bonuses for Stacks',
    body:
        'A Stack that includes more than one color (blue, red, orange, or gray) of Scoring Object receives additional points based on the number of colors in that Stack, up to three colors. 2-color Stack = 5-point bonus. 3-color Stack = 15-point bonus (replaces the 5-point bonus). Beams count as gray and act as a "wild card" — they take on any color not already in the Stack for color-bonus purposes.',
    tags: [
      'color bonus',
      '2 colors',
      '3 colors',
      '5 points',
      '15 points',
      'wild card',
      'beam'
    ],
  ),
  const GameRule(
    id: '<SC5>',
    section: 'SC',
    title: 'Placed in a Goal',
    body:
        'A Stack is considered Placed in a Goal at the end of the Match if: (a) There are at least two Connected Scoring Objects. (b) No part of the Stack is contacting a Robot. (c) The Stack meets one of: (i) Contacting the PET sheet and entirely within the Floor Goal (max 4 Stacks). (ii) Entirely within a Square Goal (max 1 Stack per Goal). (iii) Entirely within a Triangle Goal (max 3 Stacks per Goal). (iv) Above the Standoff Goal: Connected to the Standoff Goal, or Connected up from a Beam that is Connected to the Standoff Goal, or Connected up from a Beam in another Stack Connected to the Standoff Goal.',
    tags: [
      'placed',
      'goal',
      'floor goal',
      'square goal',
      'triangle goal',
      'standoff goal'
    ],
  ),
  const GameRule(
    id: '<SC6>',
    section: 'SC',
    title: 'Matching Goal bonus',
    body:
        'A Stack earns a Matching Goal bonus (10 points) when one or more of the following is met: (a) The Stack is Placed in a Goal with a color that matches the bottom Pin in that Stack. (b) The Stack is Connected to a Beam. Each Stack can earn a maximum of one (1) Matching Goal bonus.',
    tags: ['matching goal', '10 points', 'bottom pin', 'beam', 'bonus'],
  ),
  const GameRule(
    id: '<SC7>',
    section: 'SC',
    title: 'Cleared Starting Pin',
    body:
        'A Starting Pin is Cleared if no part of its Starting Pin Support is within the volume of a Pin at the end of the Match. Each Cleared Starting Pin earns 2 points.',
    tags: ['cleared', 'starting pin', '2 points', 'starting pin support'],
  ),
  const GameRule(
    id: '<SC8>',
    section: 'SC',
    title: 'Robot in contact with Scoring Objects',
    body:
        'A Robot will receive 2 points for ending the Match in contact with Scoring Objects in the following scenarios: (a) The Robot is directly contacting two or more Scoring Objects. (b) The Robot is directly contacting a Scoring Object that is fully nested with one or more additional Scoring Objects. Note: Stacks being touched by a Robot score zero points per <SC3>, but the Robot still earns this 2-point bonus.',
    tags: ['robot contact', '2 points', 'end of match', 'nested'],
  ),

  // ═══════════════════════════════════════════
  //  R – Robot Rules (Inspection)
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<R1>',
    section: 'R',
    title: 'All Robots must pass inspection',
    body:
        'No Team may compete in any Qualification Match, Finals Match, or Robot Skills Match until their Robot has passed inspection. The Robot must re-pass inspection before competing in any Match if any changes are made after the initial inspection that would affect Rule compliance.',
    tags: ['inspection', 'qualification', 'compliance'],
  ),
  const GameRule(
    id: '<R2>',
    section: 'R',
    title: 'Inspections may happen at any time',
    body:
        'Robots may be inspected or re-inspected at any time during an event at the Head Referee\'s discretion. Teams who do not produce their Robot for re-inspection may be Disqualified from subsequent Matches.',
    tags: ['re-inspection', 'any time', 'disqualification'],
  ),
  const GameRule(
    id: '<R3>',
    section: 'R',
    title: 'Robot inspection process',
    body:
        'When presenting for an inspection, the Robot must be in its starting position configuration and turned on. Teams must present all items that will be used during competition. Students must carry their Robot to the inspection table. Event staff are allowed to take pictures of Robots as needed.',
    tags: ['inspection process', 'starting position', 'turned on'],
  ),
  const GameRule(
    id: '<R4>',
    section: 'R',
    title: 'One Robot per Team',
    body:
        'Each Team must build one (1) Robot, and only that Robot may represent the Team during the event. A Team cannot bring multiple Robots and choose the "best" one before the event.',
    tags: ['one robot', 'single robot'],
  ),
  const GameRule(
    id: '<R5>',
    section: 'R',
    title: 'Robot size limit',
    body:
        'Robots must fit within an 11" wide × 20" long × 15" tall (279mm × 508mm × 381mm) volume. The Robot will be placed into a "sizing box" during inspection to confirm. Prior to the start of a Match, the Robot must satisfy this constraint. During a Match, horizontal expansion beyond 11" × 20" is prohibited (see <SG2>), but vertical expansion beyond 15" is unlimited (see <SG3>).',
    tags: ['size limit', '11 × 20 × 15', 'sizing box', 'footprint'],
  ),
  const GameRule(
    id: '<R6>',
    section: 'R',
    title: 'Team numbers on License Plates',
    body:
        'Officially registered Team numbers must be displayed on exactly two (2) VEX IQ Robotics Competition License Plates on opposing sides of the Robot. License Plates must be clearly visible at all times.',
    tags: ['license plates', 'team number', 'visible'],
  ),
  const GameRule(
    id: '<R7>',
    section: 'R',
    title: 'Let it go after the Match',
    body:
        'Robots must be designed to permit easy removal of Scoring Objects from their Robot without requiring that the Robot have power or remote control after the Match is over.',
    tags: ['release', 'scoring objects', 'post-match'],
  ),
  const GameRule(
    id: '<R8>',
    section: 'R',
    title: 'Robots have one Brain',
    body:
        'Robots are limited to one (1) VEX IQ Robot Brain. Any other microcontrollers or processing devices are not allowed, even as non-functional decorations.',
    tags: ['one brain', 'microcontroller', 'electronics'],
  ),
  const GameRule(
    id: '<R9>',
    section: 'R',
    title: 'Keep the power button accessible',
    body:
        'The on/off button on the VEX IQ Robot Brain must be accessible without moving or lifting the Robot. All screens and/or lights must also be easily visible by competition personnel.',
    tags: ['power button', 'accessible', 'screens', 'lights'],
  ),
  const GameRule(
    id: '<R10>',
    section: 'R',
    title: 'Firmware',
    body:
        'Teams must use VEXos version 2.2.1 or newer on Gen1 Brains, or VEXos version 1.0.8 or newer on Gen2 Brains. When the minimum version is updated, Teams have a 14-day grace period.',
    tags: ['firmware', 'VEXos', 'gen1', 'gen2', 'update'],
  ),
  const GameRule(
    id: '<R11>',
    section: 'R',
    title: 'Motor limits',
    body:
        'Robots may use up to six (6) motors (any combination of Smart Motors and/or standard IQ motors). Additional motors not connected to a port are still considered part of the Robot and count toward this limit.',
    tags: ['motors', 'six motors', 'limit'],
  ),
  const GameRule(
    id: '<R12>',
    section: 'R',
    title: 'Sensor limits',
    body:
        'Robots may use any number of VEX IQ sensors, but must adhere to port availability on the VEX IQ Robot Brain.',
    tags: ['sensors', 'ports', 'VEX IQ'],
  ),
  const GameRule(
    id: '<R13>',
    section: 'R',
    title: 'One Controller per Robot',
    body:
        'No more than one (1) VEX IQ Controller may control a single Robot. No physical or electrical modification of the Controller is allowed. No other methods of controlling the Robot (light, sound, etc.) are permissible. Using sensor feedback to augment Driver control is permitted.',
    tags: ['one controller', 'no modification', 'sensor feedback'],
  ),
  const GameRule(
    id: '<R14>',
    section: 'R',
    title: 'Robots are built from the VEX IQ product line',
    body:
        'Robots may be built ONLY from official Robot components from the VEX IQ product line, unless otherwise specifically noted. Official VEX IQ products are ONLY available from VEX Robotics.',
    tags: ['VEX IQ parts', 'official components', 'legal parts'],
  ),
  const GameRule(
    id: '<R15>',
    section: 'R',
    title: 'Prohibited items',
    body:
        'Prohibited: (a) Components that could damage Field Elements or Scoring Objects. (b) Components that could damage or entangle other Robots. (c) Grease, oil, graphite, lubricants. (d) Tape or adhesive materials (except non-functional decorations per <R17>). (e) VEX 123, V5, CTE, EXP, Cortex, or VEXpro products (unless allowed by <R16>). (f-g) Electrical components from HEXBUG or VEX GO. (h) 3D printed parts. (i) See Illegal Parts Appendix.',
    tags: ['prohibited', 'illegal parts', 'tape', '3D printing', 'lubricant'],
  ),
  const GameRule(
    id: '<R16>',
    section: 'R',
    title: 'Legal Non-VEX IQ components',
    body:
        'Legal additions: (a) Rubber bands (#32, #64, #117B, #170). (b) ⅛" metal shafts from VEX V5. (c) Cross-listed V5/IQ products. (d) Mechanical/structural HEXBUG components. (e) Mechanical/structural VEX GO components. (f) Aerosol cooling/freeze spray for motors. (g) Cleaners/disinfectants for Robot parts.',
    tags: ['legal non-VEX', 'rubber bands', 'metal shafts', 'HEXBUG', 'VEX GO'],
  ),
  const GameRule(
    id: '<R17>',
    section: 'R',
    title: 'Decorations are allowed',
    body:
        'Teams may add non-functional decorations, provided they are in the spirit of an educational competition. Decorations must be backed by legal materials that provide the same functionality. Non-toxic paint is considered a legal non-functional decoration (but not as adhesive).',
    tags: ['decorations', 'non-functional', 'paint', 'spirit'],
  ),
  const GameRule(
    id: '<R18>',
    section: 'R',
    title: 'Pneumatics',
    body:
        'Robots using VEX IQ Pneumatics Kit (228-8795) must have: no more than two (2) Air Tanks (including any not connected), no more than one (1) Air Pump. No additional non-kit parts (e.g., unofficial tubing or fittings). No limit on Pneumatic Cylinders or Solenoids.',
    tags: ['pneumatics', 'air tank', 'air pump', 'cylinders'],
  ),
  const GameRule(
    id: '<R19>',
    section: 'R',
    title: 'Modifications of parts',
    body:
        'Parts may NOT be modified unless specifically listed as an exception. Illegal modifications include bending, cutting, sanding, gluing, lubricating, or otherwise altering VEX IQ parts from their original state.',
    tags: ['modifications', 'cutting', 'bending', 'gluing', 'illegal'],
  ),

  // ═══════════════════════════════════════════
  //  RSC – Robot Skills Challenge
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<RSC1>',
    section: 'RSC',
    title: 'Standard rules apply',
    body:
        'All rules from previous sections apply to Robot Skills Matches, unless otherwise specified in this section.',
    tags: ['skills', 'standard rules', 'apply'],
  ),
  const GameRule(
    id: '<RSC2>',
    section: 'RSC',
    title: 'Skills field setup',
    body:
        'The Robot Skills Field is set up the same as the Teamwork Fields used in Qualification and Finals Matches for that event. The Field must be set up in accordance with Appendix A and <T5>.',
    tags: ['skills field', 'setup', 'same as teamwork'],
  ),
  const GameRule(
    id: '<RSC3>',
    section: 'RSC',
    title: 'Starting position for Robot Skills',
    body:
        'A Robot participating in a Driving Skills Match or Autonomous Coding Skills Match must meet all the criteria in <SG1>, using either Triangle Goal as their starting position. The Robot may use one (1) blue or red Pin as a Preload.',
    tags: ['skills starting', 'triangle goal', 'preload'],
  ),
  const GameRule(
    id: '<RSC4>',
    section: 'RSC',
    title: 'Robot Skills Scoring',
    body:
        'Scoring in Robot Skills Matches follows the same rules as Teamwork Matches, treating a single Team\'s score as both the Alliance Score and that Team\'s individual score. However, the "Robot in contact with Scoring Objects" bonus (<SC8>) can only be earned once per Robot Skills Match.',
    tags: ['skills scoring', 'alliance score', 'single team'],
  ),
  const GameRule(
    id: '<RSC5>',
    section: 'RSC',
    title: 'Robot reset during Skills',
    body:
        'During a Robot Skills Match, a Robot can be handled and reset similar to <GG10>. The Driver must signal the Head Referee by placing their Controller on the ground. The Robot can be placed in contact with either Triangle Goal. A Loader may Load one Pin into a Load Zone before the Robot resumes.',
    tags: ['skills reset', 'controller down', 'triangle goal'],
  ),
  const GameRule(
    id: '<RSC6>',
    section: 'RSC',
    title: 'Driving Skills Match format',
    body:
        'A Driving Skills Match consists of a sixty-second (one minute) Driver Controlled Period. There is no Autonomous Period. One Driver operates the Robot for the entire Match (no Driver switch required). Teams can end a Driving Skills Match early to record a Skills Stop Time.',
    tags: ['driving skills', '60 seconds', 'one driver', 'stop time'],
  ),
  const GameRule(
    id: '<RSC7>',
    section: 'RSC',
    title: 'Autonomous Coding Skills Match format',
    body:
        'An Autonomous Coding Skills Match consists of a sixty-second (one minute) Autonomous Period. There is no Driver Controlled Period. A Robot may run one or more programs during the Match. Teams cannot use Robot controllers for any purpose during Autonomous Coding Skills Matches.',
    tags: ['autonomous skills', '60 seconds', 'coding', 'no controller'],
  ),
  const GameRule(
    id: '<RSC8>',
    section: 'RSC',
    title: 'Ending a Skills Match early',
    body:
        'In a Driving Skills Match, the Driver can choose to end the Match early at any time. In an Autonomous Coding Skills Match, the Team can choose to end the Match early at any time. The Skills Stop Time is recorded as the time remaining on the Match timer. This is used as a tiebreaker in Skills rankings.',
    tags: ['early end', 'stop time', 'tiebreaker', 'skills'],
  ),

  // ═══════════════════════════════════════════
  //  T – Tournament Rules (selected)
  // ═══════════════════════════════════════════
  const GameRule(
    id: '<T1>',
    section: 'T',
    title: 'The Head Referee has the final say',
    body:
        'The Head Referee has ultimate and final authority on all rulings during the event. The Head Referee may consult with assistant referees and event staff, but their decision is final for any Match-related call.',
    tags: ['head referee', 'final authority', 'rulings'],
  ),
  const GameRule(
    id: '<T2>',
    section: 'T',
    title: 'Verbal cues during the Match',
    body:
        'The referees will make verbal cues at the start and end of the Match. If Tournament Manager is being used, audio tones will accompany these cues.',
    tags: ['verbal cues', 'start', 'end', 'tournament manager'],
  ),
  const GameRule(
    id: '<T3>',
    section: 'T',
    title: 'Drive Team Members may discuss rulings',
    body:
        'If there is a concern regarding the ruling or score of a Match, only the Drive Team Members from that Match (not an Adult) may question or discuss the Match with the Head Referee. Questions must be raised prior to the start of the next Match on that Field. No video or photographic evidence is allowed.',
    tags: ['discuss rulings', 'drive team only', 'no adults', 'no video'],
  ),
  const GameRule(
    id: '<T5>',
    section: 'T',
    title: 'Field setup requirements',
    body:
        'The Field must be set up in accordance with Appendix A. Scoring Object positions must follow the starting configuration diagram. Pin rotation does not matter. Event Partners should ensure all Fields are consistent with each other.',
    tags: ['field setup', 'appendix A', 'starting configuration', 'consistent'],
  ),
  const GameRule(
    id: '<T14>',
    section: 'T',
    title: 'Finals Match format',
    body:
        'Finals Matches are played as best-of-three series. The first Alliance to win two (2) Matches wins the Finals. If the third Match results in a tie, the Alliance that stopped the Match first (earliest Skills Stop Time) wins. If still tied, the higher-ranked Alliance from Qualifications advances.',
    tags: ['finals', 'best of three', 'tiebreaker', 'alliance'],
  ),
  const GameRule(
    id: '<T15>',
    section: 'T',
    title: 'Robot Skills attempts',
    body:
        'At a standard event, Teams are permitted up to three (3) Driving Skills Matches and three (3) Autonomous Coding Skills Matches. Only each Team\'s highest score in each type counts toward their combined Robot Skills ranking.',
    tags: ['skills attempts', 'three each', 'highest score', 'ranking'],
  ),
];

class GameManualTab extends StatefulWidget {
  const GameManualTab({super.key});

  @override
  State<GameManualTab> createState() => _GameManualTabState();
}

class _GameManualTabState extends State<GameManualTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _activeSection;
  String _searchQuery = '';

  List<GameRule> get _filteredRules {
    var rules = kGameManualRules.toList();

    if (_activeSection != null) {
      rules = rules.where((r) => r.section == _activeSection).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      rules = rules.where((r) {
        return r.id.toLowerCase().contains(q) ||
            r.title.toLowerCase().contains(q) ||
            r.body.toLowerCase().contains(q) ||
            r.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    return rules;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final filtered = _filteredRules;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Search rules, tags, or rule numbers...',
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: CupertinoColors.label),
          ),
        ),

        // Section quick-filter chips + PDF button
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildChip('All', null, primaryColor),
              for (final section in kManualSections)
                _buildChip(
                  '${kSectionNames[section]} ($section)',
                  section,
                  primaryColor,
                ),
              // PDF button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: _openPdf,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: CupertinoColors.tertiarySystemFill,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.doc_text,
                            size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'View PDF',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Rules list
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No rules found.',
                    style: TextStyle(
                      color: CupertinoColors.inactiveGray,
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final rule = filtered[index];
                    final isFirstOfSection = index == 0 ||
                        filtered[index - 1].section != rule.section;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstOfSection) ...[
                          if (index > 0) const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.2),
                                  primaryColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${kSectionNames[rule.section]} (${rule.section})',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        _buildRuleCard(rule, primaryColor),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openPdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/game_manual.pdf');

      // Always copy to ensure we have the latest version if the asset changes
      final data = await rootBundle.load('assets/pdfs/game_manual.pdf');
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PDFViewerScreen(
            filePath: file.path,
            title: 'Game Manual',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Could not open the game manual PDF.\n\nDetails: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildChip(String label, String? section, Color primaryColor) {
    final isActive = _activeSection == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSection = section;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : CupertinoColors.label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(GameRule rule, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule ID + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rule.id,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rule.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Body
          Text(
            rule.body,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: rule.tags.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  setState(() => _searchQuery = tag);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: CupertinoColors.tertiarySystemFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
