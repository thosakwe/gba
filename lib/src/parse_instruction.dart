import 'program_counter.dart';
import 'instruction.dart';

const Map oneByteInstrs = const {
  0: 'NOP',
  1: 'LD BC,nn',
  2: 'LD (BC),A',
  3: 'INC BC',
  4: 'INC B',
  5: 'DEC B',
  6: 'LD B,n',
  7: 'RLC A',
  8: 'LD (nn),SP',
  9: 'ADD HL,BC',
  10: 'LD A,(BC)',
  11: 'DEC BC',
  12: 'INC C',
  13: 'DEC C',
  14: 'LD C,n',
  15: 'RRC A',
  16: 'STOP',
  17: 'LD DE,nn',
  18: 'LD (DE),A',
  19: 'INC DE',
  20: 'INC D',
  21: 'DEC D',
  22: 'LD D,n',
  23: 'RL A',
  24: 'JR n',
  25: 'ADD HL,DE',
  26: 'LD A,(DE)',
  27: 'DEC DE',
  28: 'INC E',
  29: 'DEC E',
  30: 'LD E,n',
  31: 'RR A',
  32: 'JR NZ,n',
  33: 'LD HL,nn',
  34: 'LDI (HL),A',
  35: 'INC HL',
  36: 'INC H',
  37: 'DEC H',
  38: 'LD H,n',
  39: 'DAA',
  40: 'JR Z,n',
  41: 'ADD HL,HL',
  42: 'LDI A,(HL)',
  43: 'DEC HL',
  44: 'INC L',
  45: 'DEC L',
  46: 'LD L,n',
  47: 'CPL',
  48: 'JR NC,n',
  49: 'LD SP,nn',
  50: 'LDD (HL),A',
  51: 'INC SP',
  52: 'INC (HL)',
  53: 'DEC (HL)',
  54: 'LD (HL),n',
  55: 'SCF',
  56: 'JR C,n',
  57: 'ADD HL,SP',
  58: 'LDD A,(HL)',
  59: 'DEC SP',
  60: 'INC A',
  61: 'DEC A',
  62: 'LD A,n',
  63: 'CCF',
  64: 'LD B,B',
  65: 'LD B,C',
  66: 'LD B,D',
  67: 'LD B,E',
  68: 'LD B,H',
  69: 'LD B,L',
  70: 'LD B,(HL)',
  71: 'LD B,A',
  72: 'LD C,B',
  73: 'LD C,C',
  74: 'LD C,D',
  75: 'LD C,E',
  76: 'LD C,H',
  77: 'LD C,L',
  78: 'LD C,(HL)',
  79: 'LD C,A',
  80: 'LD D,B',
  81: 'LD D,C',
  82: 'LD D,D',
  83: 'LD D,E',
  84: 'LD D,H',
  85: 'LD D,L',
  86: 'LD D,(HL)',
  87: 'LD D,A',
  88: 'LD E,B',
  89: 'LD E,C',
  90: 'LD E,D',
  91: 'LD E,E',
  92: 'LD E,H',
  93: 'LD E,L',
  94: 'LD E,(HL)',
  95: 'LD E,A',
  96: 'LD H,B',
  97: 'LD H,C',
  98: 'LD H,D',
  99: 'LD H,E',
  100: 'LD H,H',
  101: 'LD H,L',
  102: 'LD H,(HL)',
  103: 'LD H,A',
  104: 'LD L,B',
  105: 'LD L,C',
  106: 'LD L,D',
  107: 'LD L,E',
  108: 'LD L,H',
  109: 'LD L,L',
  110: 'LD L,(HL)',
  111: 'LD L,A',
  112: 'LD (HL),B',
  113: 'LD (HL),C',
  114: 'LD (HL),D',
  115: 'LD (HL),E',
  116: 'LD (HL),H',
  117: 'LD (HL),L',
  118: 'HALT',
  119: 'LD (HL),A',
  120: 'LD A,B',
  121: 'LD A,C',
  122: 'LD A,D',
  123: 'LD A,E',
  124: 'LD A,H',
  125: 'LD A,L',
  126: 'LD A,(HL)',
  127: 'LD A,A',
  128: 'ADD A,B',
  129: 'ADD A,C',
  130: 'ADD A,D',
  131: 'ADD A,E',
  132: 'ADD A,H',
  133: 'ADD A,L',
  134: 'ADD A,(HL)',
  135: 'ADD A,A',
  136: 'ADC A,B',
  137: 'ADC A,C',
  138: 'ADC A,D',
  139: 'ADC A,E',
  140: 'ADC A,H',
  141: 'ADC A,L',
  142: 'ADC A,(HL)',
  143: 'ADC A,A',
  144: 'SUB A,B',
  145: 'SUB A,C',
  146: 'SUB A,D',
  147: 'SUB A,E',
  148: 'SUB A,H',
  149: 'SUB A,L',
  150: 'SUB A,(HL)',
  151: 'SUB A,A',
  152: 'SBC A,B',
  153: 'SBC A,C',
  154: 'SBC A,D',
  155: 'SBC A,E',
  156: 'SBC A,H',
  157: 'SBC A,L',
  158: 'SBC A,(HL)',
  159: 'SBC A,A',
  160: 'AND B',
  161: 'AND C',
  162: 'AND D',
  163: 'AND E',
  164: 'AND H',
  165: 'AND L',
  166: 'AND (HL)',
  167: 'AND A',
  168: 'XOR B',
  169: 'XOR C',
  170: 'XOR D',
  171: 'XOR E',
  172: 'XOR H',
  173: 'XOR L',
  174: 'XOR (HL)',
  175: 'XOR A',
  176: 'OR B',
  177: 'OR C',
  178: 'OR D',
  179: 'OR E',
  180: 'OR H',
  181: 'OR L',
  182: 'OR (HL)',
  183: 'OR A',
  184: 'CP B',
  185: 'CP C',
  186: 'CP D',
  187: 'CP E',
  188: 'CP H',
  189: 'CP L',
  190: 'CP (HL)',
  191: 'CP A',
  192: 'RET NZ',
  193: 'POP BC',
  194: 'JP NZ,nn',
  195: 'JP nn',
  196: 'CALL NZ,nn',
  197: 'PUSH BC',
  198: 'ADD A,n',
  199: 'RST 0',
  200: 'RET Z',
  201: 'RET',
  202: 'JP Z,nn',
  203: 'Ext ops',
  204: 'CALL Z,nn',
  205: 'CALL nn',
  206: 'ADC A,n',
  207: 'RST 8',
  208: 'RET NC',
  209: 'POP DE',
  210: 'JP NC,nn',
  211: 'XX',
  212: 'CALL NC,nn',
  213: 'PUSH DE',
  214: 'SUB A,n',
  215: 'RST 10',
  216: 'RET C',
  217: 'RETI',
  218: 'JP C,nn',
  219: 'XX',
  220: 'CALL C,nn',
  221: 'XX',
  222: 'SBC A,n',
  223: 'RST 18',
  224: 'LDH (n),A',
  225: 'POP HL',
  226: 'LDH (C),A',
  227: 'XX',
  228: 'XX',
  229: 'PUSH HL',
  230: 'AND n',
  231: 'RST 20',
  232: 'ADD SP,d',
  233: 'JP (HL)',
  234: 'LD (nn),A',
  235: 'XX',
  236: 'XX',
  237: 'XX',
  238: 'XOR n',
  239: 'RST 28',
  240: 'LDH A,(n)',
  241: 'POP AF',
  242: 'XX',
  243: 'DI',
  244: 'XX',
  245: 'PUSH AF',
  246: 'OR n',
  247: 'RST 30',
  248: 'LDHL SP,d',
  249: 'LD SP,HL',
  250: 'LD A,(nn)',
  251: 'EI',
  252: 'XX',
  253: 'XX',
  254: 'CP n',
  255: 'RST 38'
};
Instruction parseInstruction(ProgramCounter reader) {
  var op = reader.uint8;

  if (op == 0xCB) throw 'Prefix!';

  for (var key in oneByteInstrs.keys) {
    if (op == key)
      return new Instruction(
        oneByteInstrs[key],
        key,
        null,
      );
  }

  throw ("Malformed opcode: 0x" + op.toRadixString(16));
}
