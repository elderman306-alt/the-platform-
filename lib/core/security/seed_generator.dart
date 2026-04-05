// 🔷 THE PLATFORM - Seed Generator
// BIP-39 15-word seed phrase generation and recovery

import 'dart:math';
import 'dart:typed_data';
import 'package:the_platform-/core/security/auth_service.dart';

/// ==========================================
/// SEED GENERATOR SERVICE
/// ==========================================

class SeedGenerator {
  static final SeedGenerator _instance = SeedGenerator._internal();
  factory SeedGenerator() => _instance;
  SeedGenerator._internal();

  // BIP-39 Word List (first 2048 words abbreviated for demo)
  static const List<String> _bip39Words = [
    'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract',
    'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid',
    'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual',
    'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance',
    'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'age', 'agent',
    'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album',
    'alcohol', 'alert', 'alien', 'all', 'alley', 'allow', 'almost', 'alone',
    'alpha', 'already', 'also', 'alter', 'always', 'amateur', 'amazing',
    'among', 'amount', 'amused', 'analyst', 'anchor', 'ancient', 'anger', 'angle',
    'angry', 'animal', 'ankle', 'announce', 'annual', 'another', 'answer',
    'antenna', 'antique', 'anxiety', 'any', 'apart', 'apology', 'appear',
    'apple', 'approve', 'april', 'arch', 'arctic', 'area', 'arena', 'argue',
    'arm', 'armed', 'armor', 'army', 'around', 'arrange', 'arrest', 'arrive',
    'arrow', 'art', 'artefact', 'artist', 'artwork', 'ask', 'aspect', 'assault',
    'asset', 'assist', 'assume', 'asthma', 'athlete', 'atom', 'attack', 'attend',
    'attitude', 'attract', 'auction', 'audit', 'august', 'aunt', 'author',
    'auto', 'autumn', 'average', 'avocado', 'avoid', 'awake', 'aware', 'away',
    'awesome', 'awful', 'awkward', 'axis', 'baby', 'bachelor', 'bacon', 'badge',
    'bag', 'balance', 'balcony', 'ball', 'bamboo', 'banana', 'banner', 'bar',
    'barely', 'bargain', 'barrel', 'base', 'basic', 'basket', 'battle',
    'beach', 'bean', 'beauty', 'because', 'become', 'beef', 'before',
    'begin', 'behave', 'behind', 'believe', 'below', 'belt', 'bench', 'benefit',
    'best', 'betray', 'better', 'between', 'beyond', 'bicycle', 'bid', 'bike',
    'bind', 'biology', 'bird', 'birth', 'bitter', 'black', 'blade', 'blame',
    'blanket', 'blast', 'blaze', 'bless', 'blind', 'blood', 'blossom', 'blouse',
    'blue', 'blur', 'blush', 'board', 'boat', 'body', 'boil', 'bomb', 'bone',
    'bonus', 'book', 'boost', 'border', 'boring', 'borrow', 'boss', 'bottom',
    'bounce', 'box', 'boy', 'bracket', 'brain', 'brand', 'brass', 'brave',
    'bread', 'breeze', 'brick', 'bridge', 'brief', 'bright', 'bring', 'brisk',
    'broccoli', 'broken', 'bronze', 'broom', 'brother', 'brown', 'brush', 'bubble',
    'bucket', 'budget', 'buffalo', 'build', 'bulb', 'bulk', 'bullet', 'bundle',
    'bunker', 'burden', 'burger', 'burst', 'bus', 'business', 'busy', 'butter',
    'buyer', 'buzz', 'cabbage', 'cabin', 'cable', 'cactus', 'cage', 'cake',
    'call', 'calm', 'camera', 'camp', 'can', 'canal', 'cancel', 'candy', 'cannon',
    'canoe', 'canvas', 'canyon', 'capable', 'capital', 'captain', 'car', 'carbon',
    'card', 'cargo', 'carpet', 'carry', 'cart', 'case', 'cash', 'casino', 'castle',
    'casual', 'cat', 'catalog', 'catch', 'category', 'cattle', 'caught', 'cause',
    'caution', 'cave', 'ceiling', 'celery', 'cement', 'census', 'century', 'cereal',
    'certain', 'chair', 'chalk', 'champion', 'change', 'chaos', 'chapter',
    'charge', 'chase', 'chat', 'cheap', 'check', 'cheese', 'chef', 'cherry',
    'chest', 'chicken', 'chief', 'child', 'chimney', 'choice', 'choose',
    'chronic', 'chuckle', 'chunk', 'churn', 'cigar', 'cinnamon', 'circle',
    'citizen', 'city', 'civil', 'claim', 'clap', 'clarify', 'classic', 'clean',
    'clever', 'click', 'client', 'cliff', 'climb', 'clinic', 'clip', 'clock',
    'close', 'cloth', 'cloud', 'clown', 'club', 'clump', 'cluster', 'clutch',
    'coach', 'coast', 'coconut', 'code', 'coffee', 'coil', 'coin', 'collect',
    'color', 'column', 'combine', 'come', 'comfort', 'comic', 'common', 'company',
    'concert', 'conduct', 'confirm', 'congress', 'connect', 'consider', 'control',
    'convince', 'cook', 'cool', 'copper', 'copy', 'coral', 'core', 'corn', 'correct',
    'cost', 'cottage', 'cotton', 'couch', 'country', 'couple', 'course', 'cousin',
    'cover', 'coyote', 'crack', 'cradle', 'craft', 'cram', 'crane', 'crash',
    'crater', 'crawl', 'crazy', 'cream', 'credit', 'creek', 'crew', 'cricket',
    'crime', 'crisp', 'critic', 'crop', 'cross', 'crouch', 'crowd', 'crucial',
    'cruel', 'cruise', 'crumble', 'crunch', 'crush', 'cry', 'crystal', 'cube',
    'culture', 'cup', 'cupboard', 'curious', 'current', 'curtain', 'curve',
    'cushion', 'custom', 'cute', 'cycle', 'dad', 'damage', 'damp', 'dance', 'danger',
    'daring', 'daughter', 'dawn', 'day', 'deal', 'debate', 'debris', 'decade',
    'december', 'decide', 'decline', 'decorate', 'decrease', 'deer', 'defense',
    'define', 'defy', 'degree', 'delay', 'deliver', 'democracy', 'deny', 'depart',
    'depend', 'deposit', 'depth', 'deputy', 'derive', 'describe', 'desert',
    'design', 'desk', 'despair', 'destroy', 'detail', 'detect', 'develop', 'device',
    'devote', 'diagram', 'dial', 'diamond', 'diary', 'dice', 'diesel', 'diet',
    'differ', 'digital', 'dignity', 'dilemma', 'dinner', 'dinosaur', 'direct',
    'dirt', 'disagree', 'discover', 'disease', 'dish', 'dismiss', 'disorder',
    'display', 'distance', 'divert', 'divide', 'divorce', 'dizzy', 'doctor', 'document',
    'dog', 'doll', 'dolphin', 'domain', 'donate', 'donkey', 'donor', 'door',
    'dose', 'double', 'dove', 'dragon', 'drama', 'draw', 'dream', 'dress', 'drift',
    'drill', 'drink', 'drip', 'drive', 'drop', 'drum', 'dry', 'duck', 'dumb',
    'dune', 'during', 'dusk', 'dust', 'duty', 'dwarf', 'dynamic', 'eager', 'eagle',
    'early', 'earn', 'earth', 'easily', 'east', 'easy', 'echo', 'ecology',
    'economy', 'edge', 'edit', 'educate', 'effort', 'egg', 'eight', 'eject',
    'elastic', 'elbow', 'elder', 'electric', 'elegant', 'element', 'elephant',
    'elevator', 'elite', 'else', 'embark', 'embody', 'embrace', 'emerge',
    'emotion', 'employ', 'empower', 'empty', 'enable', 'enact', 'end', 'endure',
    'energy', 'enforce', 'engage', 'engine', 'enhance', 'enjoy', 'enlist',
    'enough', 'enrich', 'enroll', 'ensure', 'enter', 'entire', 'entry', 'envelope',
    'episode', 'equal', 'equip', 'era', 'erase', 'erode', 'erosion', 'error',
    'erupt', 'escape', 'essay', 'essence', 'estate', 'eternal', 'ethics', 'evil',
    'evoke', 'evolve', 'exact', 'example', 'excess', 'exchange', 'excite',
    'exclude', 'excuse', 'execute', 'exercise', 'exhaust', 'exhibit', 'exile',
    'exist', 'exit', 'exotic', 'expand', 'expect', 'expel', 'explain', 'explode',
    'explore', 'expose', 'express', 'extend', 'extra', 'eye', 'eyebrow', 'fabric',
    'face', 'faculty', 'fade', 'faint', 'faith', 'fall', 'False', 'fame',
    'family', 'famous', 'fan', 'fancy', 'fantasy', 'farm', 'fashion', 'fat', 'fatal',
    'father', 'fatigue', 'fault', 'favorite', 'feature', 'february', 'federal', 'fee',
    'feed', 'feel', 'female', 'fence', 'festival', 'fetch', 'fever', 'few', 'fiber',
    'fiction', 'field', 'figure', 'file', 'film', 'filter', 'final', 'find',
    'fine', 'finger', 'finish', 'fire', 'firm', 'first', 'fiscal', 'fish', 'fit',
    'fitness', 'fix', 'flag', 'flame', 'flash', 'flat', 'flavor', 'flee', 'flight',
    'flip', 'float', 'flock', 'floor', 'flower', 'fluid', 'flush', 'fly', 'foam',
    'focus', 'fog', 'foil', 'fold', 'follow', 'food', 'foot', 'force', 'forest',
    'forget', 'fork', 'fortune', 'forum', 'forward', 'fossil', 'foster', 'found',
    'fox', 'fragile', 'frame', 'frequent', 'fresh', 'friend', 'fringe', 'frog',
    'front', 'frost', 'frown', 'frozen', 'fruit', 'fuel', 'fun', 'funny',
    'furnace', 'fury', 'future', 'gadget', 'gain', 'galaxy', 'gallery', 'game',
    'gap', 'garage', 'garbage', 'garden', 'garlic', 'gas', 'gasp', 'gate', 'gather',
    'gauge', 'gaze', 'general', 'genius', 'genre', 'gentle', 'genuine', 'gesture',
    'ghost', 'giant', 'gift', 'giggle', 'ginger', 'giraffe', 'girl', 'give', 'glad',
    'glance', 'glare', 'glass', 'glide', 'glimpse', 'globe', 'gloom', 'glory',
    'glove', 'glow', 'glue', 'goat', 'goddess', 'gold', 'good', 'goose', 'gorilla',
    'gospel', 'gossip', 'govern', 'gown', 'grab', 'grace', 'grain', 'grant',
    'grape', 'grass', 'gravity', 'great', 'green', 'grid', 'grief', 'grit',
    'grocery', 'group', 'grow', 'grunt', 'guard', 'guess', 'guide', 'guilt',
    'guitar', 'gun', 'gym', 'habit', 'hair', 'half', 'hammer', 'hamster', 'hand',
    'handle', 'harbor', 'hard', 'harsh', 'harvest', 'hat', 'have', 'hawk',
    'hazard', 'head', 'health', 'heart', 'heavy', 'hedgehog', 'height', 'hello',
    'helmet', 'help', 'hen', 'hero', 'hidden', 'high', 'hill', 'hint', 'hippo',
    'hire', 'history', 'hit', 'hobby', 'hockey', 'hold', 'hole', 'holiday',
    'hollow', 'home', 'honey', 'hood', 'hope', 'horn', 'horror', 'horse', 'hospital',
    'host', 'hotel', 'hour', 'hover', 'hub', 'huge', 'human', 'humble', 'humor',
    'hundred', 'hungry', 'hunt', 'hurdle', 'hurry', 'hurt', 'husband', 'hybrid',
    'ice', 'icon', 'idea', 'identify', 'ignore', 'ill', 'illegal', 'illness', 'image',
    'imitate', 'immense', 'immune', 'impact', 'impose', 'improve', 'impulse',
    'inch', 'include', 'income', 'increase', 'index', 'indicate', 'indoor', 'industry',
    'infant', 'inflict', 'inform', 'inhale', 'inherit', 'initial', 'inject', 'injury',
    'inmate', 'inner', 'innocent', 'input', 'inquiry', 'insane', 'insect', 'inside',
    'inspire', 'install', 'intact', 'interest', 'into', 'invest', 'invite', 'involve',
    'iron', 'island', 'isolate', 'issue', 'item', 'ivory', 'jacket', 'jaguar',
    'jar', 'jazz', 'jealous', 'jeans', 'jelly', 'jewel', 'job', 'join', 'joke',
    'jolly', 'journey', 'joy', 'judge', 'juice', 'jump', 'jungle', 'junior', 'junk',
    'just', 'kangaroo', 'keen', 'keep', 'ketchup', 'key', 'kick', 'kid', 'kidney',
    'kind', 'kingdom', 'kiss', 'kit', 'kitchen', 'kite', 'kitten', 'kiwi', 'knee',
    'knife', 'knock', 'know', 'lab', 'label', 'labor', 'ladder', 'lady', 'lake',
    'lamb', 'lamp', 'language', 'laptop', 'large', 'later', 'latin', 'laugh',
    'laundry', 'lava', 'law', 'lawn', 'lawsuit', 'layer', 'lazy', 'leader', 'leaf',
    'lean', 'leap', 'learn', 'least', 'leave', 'lecture', 'left', 'leg', 'legal',
    'legend', 'leisure', 'lemon', 'lend', 'length', 'leopard', 'lesson', 'letter',
    'level', 'liar', 'liberty', 'library', 'license', 'life', 'lift', 'light',
    'like', 'limb', 'limit', 'linen', 'lion', 'liquid', 'list', 'little', 'live',
    'lizard', 'load', 'loan', 'lobster', 'local', 'lock', 'logic', 'lonely', 'long',
    'loop', 'lottery', 'loud', 'lounge', 'love', 'loyal', 'luck', 'luggage', 'lumber',
    'lunar', 'lunch', 'luxury', 'lyrics', 'machine', 'mad', 'magnet', 'maid', 'mail',
    'main', 'major', 'make', 'mammal', 'man', 'manage', 'mandate', 'mango', 'mansion',
    'manual', 'maple', 'marble', 'march', 'margin', 'marine', 'market', 'marriage',
    'mask', 'mass', 'master', 'match', 'material', 'math', 'matrix', 'matter', 'maximum',
    'maze', 'meadow', 'mean', 'measure', 'meat', 'mechanic', 'medal', 'media', 'melody',
    'melt', 'member', 'memory', 'men', 'menace', 'mentor', 'menu', 'mercy', 'merge', 'merit',
    'merry', 'mesh', 'message', 'metal', 'method', 'middle', 'midnight', 'milk', 'million',
    'mimic', 'mind', 'minimum', 'minor', 'minute', 'miracle', 'mirror', 'misery', 'miss',
    'mistake', 'mix', 'mixed', 'mixture', 'mobile', 'model', 'modify', 'mom', 'moment',
    'monitor', 'monkey', 'monster', 'month', 'moon', 'moral', 'more', 'morning',
    'mosquito', 'mother', 'motion', 'motor', 'mountain', 'mouse', 'move', 'movie', 'much',
    'muffin', 'mule', 'multiply', 'muscle', 'museum', 'mushroom', 'music', 'must',
    'mutual', 'myself', 'mystery', 'myth', 'naive', 'name', 'napkin', 'narrow', 'nasty',
    'nation', 'nature', 'near', 'neck', 'need', 'negative', 'neglect', 'neither', 'nephew',
    'nerve', 'nest', 'net', 'network', 'neutral', 'never', 'news', 'next', 'nice', 'night',
    'noble', 'noise', 'nominee', 'noodle', 'normal', 'north', 'nose', 'notable', 'note',
    'nothing', 'notice', 'notion', 'novel', 'now', 'nuclear', 'number', 'nurse', 'nut', 'oak',
    'obey', 'object', 'oblige', 'obscure', 'observe', 'obtain', 'obvious', 'occur', 'ocean',
    'october', 'odor', 'off', 'offer', 'office', 'often', 'oil', 'okay', 'old', 'olive',
    'olympic', 'omit', 'once', 'one', 'onion', 'online', 'only', 'open', 'opera',
    'opinion', 'oppose', 'option', 'orange', 'orbit', 'orchard', 'order', 'ordinary',
    'organ', 'orient', 'original', 'orphan', 'ostrich', 'other', 'outdoor', 'outer',
    'output', 'outside', 'oval', 'oven', 'over', 'own', 'owner', 'oxygen', 'oyster',
    'ozone', 'pact', 'paddle', 'page', 'pair', 'palace', 'palm', 'panda', 'panel',
    'panic', 'panther', 'paper', 'parade', 'parent', 'park', 'parrot', 'party', 'pass',
    'patch', 'path', 'patient', 'patrol', 'pattern', 'pause', 'pave', 'payment', 'peace',
    'peanut', 'pear', 'peasant', 'pelican', 'pen', 'penalty', 'pencil', 'people',
    'pepper', 'perfect', 'permit', 'person', 'pet', 'phone', 'photo', 'piano', 'piece',
    'pilot', 'pinch', 'pine', 'pink', 'pint', 'pioneer', 'pipe', 'pistol', 'pitch',
    'pizza', 'place', 'planet', 'plastic', 'plate', 'play', 'please', 'pledge', 'plenty',
    'plot', 'plough', 'pluck', 'plug', 'poem', 'poet', 'point', 'polar', 'pole',
    'police', 'pond', 'pony', 'pool', 'popular', 'portion', 'position', 'possible', 'post',
    'potato', 'pottery', 'poverty', 'powder', 'power', 'practice', 'praise', 'predict',
    'prefer', 'prepare', 'present', 'pretty', 'prevent', 'price', 'pride', 'primary',
    'print', 'priority', 'prison', 'private', 'prize', 'problem', 'process', 'produce', 'profit',
    'program', 'project', 'promote', 'proof', 'property', 'prosper', 'protect', 'proud', 'provide',
    'public', 'pudding', 'pull', 'pulp', 'pulse', 'pumpkin', 'punch', 'pupil',
    'puppy', 'purchase', 'purity', 'purpose', 'purse', 'push', 'put', 'puzzle',
    'pyramid', 'quality', 'quantum', 'quarter', 'queen', 'query', 'quest', 'queue',
    'quick', 'quiet', 'quilt', 'quota', 'quote', 'rabbit', 'raccoon', 'race', 'rack',
    'radar', 'radio', 'rail', 'rain', 'raise', 'rally', 'ramp', 'ranch', 'random',
    'range', 'rapid', 'rare', 'rate', 'rather', 'raven', 'raw', 'reach', 'react',
    'read', 'real', 'realm', 'rear', 'reason', 'rebel', 'rebuild', 'recall', '接收',
    'recipe', 'record', 'recover', 'recruit', 'red', 'reduce', 'reflect', 'reform', 'refuse',
    'region', 'regret', 'regular', 'reject', 'relax', 'release', 'relief', 'rely', 'remain',
    'remember', 'remind', 'remote', 'remove', 'render', 'renew', 'rent', 'reopen', 'repair',
    'repeat', 'replace', 'reply', 'report', 'represent', 'reproduce', 'public', 'require', 'rescue', 'resemble', 'resist', 'resource', 'response', 'result', 'retire', 'retreat', 'return',
    'reunion', 'reveal', 'review', 'reward', 'rhythm', 'rib', 'ribbon', 'rice', 'rich',
    'ride', 'ridge', 'rifle', 'right', 'rigid', 'ring', 'riot', 'ripple', 'risk',
    'ritual', 'rival', 'river', 'road', 'roast', 'robot', 'robust', 'rocket', 'romance',
    'roof', 'rookie', 'room', 'root', 'rose', 'rotate', 'rotten', 'rough', 'round',
    'route', 'royal', 'rubber', 'rubble', 'ruby', 'rude', 'rug', 'rule', 'run', 'runway',
    'rural', 'sad', 'saddle', 'sadness', 'safe', 'sail', 'salad', 'salmon', 'salon', 'salt',
    'salute', 'same', 'sample', 'sand', 'satisfy', 'satoshi', 'sauce', 'sausage', 'save',
    'say', 'scale', 'scan', 'scare', 'scatter', 'scene', 'scent', 'school', 'science',
    'scissors', 'scorpion', 'scout', 'scrap', 'screen', 'script', 'scrub', 'sea',
    'search', 'season', 'seat', 'second', 'secret', 'section', 'security', 'seed', 'seek',
    'segment', 'select', 'sell', 'seminar', 'senior', 'sense', 'sentence', 'series',
    'service', 'session', 'settle', 'setup', 'seven', 'shadow', 'shaft', 'shallow', 'share',
    'shed', 'shell', 'sheriff', 'shield', 'shift', 'shine', 'ship', 'shiver', 'shock',
    'shoe', 'shoot', 'shop', 'short', 'shoulder', 'shove', 'shrimp', 'shrug', 'shuffle',
    'shun', 'shy', 'sibling', 'sick', 'side', 'siege', 'sight', 'sign', 'silent',
    'silk', 'silly', 'silver', 'similar', 'simple', 'since', 'sing', 'siren', 'sister',
    'situate', 'six', 'size', 'skate', 'sketch', 'ski', 'skill', 'skin', 'skirt', 'skull',
    'slab', 'slam', 'sleep', 'slender', 'slice', 'slide', 'slight', 'slim', 'slogan',
    'slot', 'slow', 'slush', 'small', 'smart', 'smell', 'smile', 'smoke', 'smooth',
    'snack', 'snake', 'snap', 'sniff', 'snow', 'so', 'soap', 'soccer', 'social',
    'sock', 'soda', 'sofa', 'soft', 'software', 'soil', 'solar', 'soldier', 'solid',
    'solution', 'solve', 'someone', 'song', 'soon', 'sorry', 'sort', 'soul', 'soup',
    'source', 'south', 'space', 'spare', 'spark', 'speak', 'special', 'speed', 'spell',
    'spend', 'sphere', 'spice', 'spider', 'spike', 'spin', 'spirit', 'split', 'spoil',
    'sponsor', 'spoon', 'sport', 'spot', 'spray', 'spread', 'spring', 'spy', 'square',
    'squeeze', 'squirrel', 'stable', 'stadium', 'staff', 'stage', 'stairs', 'stamp',
    'stand', 'start', 'state', 'stay', 'steak', 'steal', 'steam', 'steel', 'steep', 'stem',
    'step', 'stereo', 'stick', 'still', 'sting', 'stock', 'stomach', 'stone', 'stool', 'story',
    'stove', 'strategy', 'street', 'strike', 'strong', 'struggle', 'student', 'stuff', 'stumble',
    'style', 'subject', 'submit', 'subway', 'success', 'such', 'sudden', 'suffer', 'sugar',
    'suggest', 'suit', 'summer', 'sun', 'sunny', 'sunset', 'super', 'supply', 'supreme',
    'sure', 'surface', 'surge', 'surprise', 'surround', 'survey', 'suspect', 'sustain',
    'swallow', 'swamp', 'swap', 'swarm', 'swear', 'sweat', 'sweep', 'sweet', 'swift',
    'swim', 'swing', 'switch', 'sword', 'symbol', 'symptom', 'syrup', 'system', 'table', 'tackle',
    'tag', 'tail', 'talent', 'talk', 'tank', 'tape', 'target', 'task', 'taste', 'tattoo',
    'tattoo', 'taxi', 'team', 'tell', 'ten', 'tenant', 'tennis', 'tent', 'term',
    'test', 'text', 'thank', 'that', 'them', 'theme', 'then', 'they', 'thing', 'this',
    'thought', 'three', 'thrive', 'throw', 'thumb', 'thunder', 'ticket', 'tide', 'tiger',
    'tilt', 'timber', 'time', 'tiny', 'tip', 'tired', 'tissue', 'title', 'toast',
    'tobacco', 'toddler', 'toe', 'together', 'toilet', 'token', 'tomato', 'tomorrow', 'tone',
    'tongue', 'tonight', 'tool', 'tooth', 'top', 'topic', 'topple', 'torch', 'tornado',
    'tortoise', 'toss', 'total', 'tourist', 'toward', 'tower', 'town', 'tiger', 'track',
    'trade', 'traffic', 'tragic', 'train', 'transfer', 'trap', 'trash', 'travel', 'tray', 'treat',
    'treatment', 'tree', 'trend', 'trial', 'tribe', 'trick', 'trigger', 'trim', 'trip', 'trophy',
    'trouble', 'truck', 'true', 'truly', 'trumpet', 'trust', 'truth', 'try', 'tube', 'tuition',
    'tumble', 'tuna', 'tunnel', 'turkey', 'turn', 'turtle', 'twelve', 'twenty', 'twice',
    'twin', 'twist', 'two', 'type', 'typical', 'ugly', 'umbrella', 'unaware', 'uncle',
    'uncover', 'under', 'undo', 'unfair', 'unfold', 'unhappy', 'uniform', 'unique', 'unit',
    'universe', 'unknown', 'unlock', 'until', 'unusual', 'unveil', 'update', 'upgrade',
    'uphold', 'upon', 'upper', 'upset', 'urban', 'urge', 'usage', 'use', 'used', 'useful',
    'useless', 'usual', 'utility', 'vacant', 'vacuum', 'vague', 'valid', 'valley', 'valve',
    'van', 'vanish', 'vapor', 'various', 'vegan', 'velvet', 'vendor', 'venture', 'venue',
    'verb', 'verify', 'version', 'very', 'vessel', 'veteran', 'viable', 'vibrant',
    'vicious', 'victory', 'video', 'view', 'village', 'vintage', 'violin', 'virtual',
    'virus', 'visa', 'visit', 'visual', 'vital', 'vivid', 'vocal', 'voice', 'void', 'volcano',
    'volume', 'vote', 'voyage', 'wage', 'wagon', 'wait', 'waiter', 'wake', 'walk',
    'wall', 'walnut', 'want', 'warfare', 'warm', 'warrior', 'wash', 'wasp', 'waste', 'water',
    'wave', 'way', 'wealth', 'weapon', 'wear', 'weasel', 'weather', 'web', 'wedding',
    'weekend', 'weird', 'welcome', 'west', 'wet', 'whale', 'what', 'wheat', 'wheel',
    'when', 'where', 'whip', 'whisper', 'whistle', 'white', 'who', 'whole', 'why',
    'wicked', 'wide', 'widow', 'width', 'wife', 'wild', 'will', 'win', 'window', 'wine',
    'wing', 'wink', 'winner', 'winter', 'wire', 'wisdom', 'wise', 'wish', 'witness', 'wolf',
    'woman', 'wonder', 'wood', 'wool', 'word', 'work', 'world', 'worry', 'worth',
    'wrap', 'wreck', 'wrestle', 'wrist', 'write', 'wrong', 'yard', 'year', 'yellow',
    'you', 'young', 'youth', 'zebra', 'zero', 'zone', 'zoo',
  ];

  /// ==========================================
  /// SEED PHRASE GENERATION
  /// ==========================================

  /// Generate 15-word BIP-39 seed phrase
  String generateSeedPhrase() {
    final random = Random.secure();
    final words = <String>[];

    for (int i = 0; i < 15; i++) {
      words.add(_bip39Words[random.nextInt(_bip39Words.length)]);
    }

    return words.join(' ');
  }

  /// Generate seed from seed phrase
  Uint8List seedFromPhrase(String phrase) {
    // PBKDF2 for BIP-39
    final words = phrase.split(' ');
    if (words.length != 15) {
      throw ArgumentError('Seed phrase must be exactly 15 words');
    }

    // Simple hash for demonstration
    var hash = 0;
    for (final word in words) {
      for (int i = 0; i < word.length; i++) {
        hash = ((hash << 5) - hash) + word.codeUnitAt(i);
        hash = hash & 0xFFFFFFFF;
      }
    }

    // Generate 64 bytes
    final seed = Uint8List(64);
    for (int i = 0; i < 64; i++) {
      seed[i] = (hash >> (i % 8)) & 0xFF;
    }

    return seed;
  }

  /// Derive private key from seed
  KeyPair deriveKeyPair(String seedPhrase) {
    final seed = seedFromPhrase(seedPhrase);

    // Generate keys from seed
    final buffer = StringBuffer();
    for (int i = 0; i < 32; i++) {
      buffer.write('0123456789ABCDEF'[seed[i] & 15]);
    }

    final privateKey = buffer.toString();
    final publicKey = buffer.toString().substring(0, 32);

    return KeyPair(
      privateKey: privateKey,
      publicKey: publicKey,
    );
  }

  /// Validate seed phrase
  bool isValidSeedPhrase(String phrase) {
    final words = phrase.split(' ');
    if (words.length != 15) return false;

    for (final word in words) {
      if (!_bip39Words.contains(word.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  /// ==========================================
  /// ACCOUNT RECOVERY
  /// ==========================================

  /// Recover account with seed phrase
  Future<RecoveryResult> recoverAccount(String seedPhrase) async {
    if (!isValidSeedPhrase(seedPhrase)) {
      return RecoveryResult(
        success: false,
        error: RecoveryError.invalidSeedPhrase,
        message: 'Invalid seed phrase',
      );
    }

    // Derive account from seed
    final keyPair = deriveKeyPair(seedPhrase);

    return RecoveryResult(
      success: true,
      message: 'Account recovered successfully',
      keyPair: keyPair,
      seedPhrase: seedPhrase,
    );
  }

  /// Generate new account with seed
  Future<SeedAccount> generateAccount() async {
    final seedPhrase = generateSeedPhrase();
    final keyPair = deriveKeyPair(seedPhrase);

    return SeedAccount(
      seedPhrase: seedPhrase,
      keyPair: keyPair,
      createdAt: DateTime.now(),
    );
  }
}

/// ==========================================
/// RECOVERY RESULT
/// ==========================================

class RecoveryResult {
  final bool success;
  final RecoveryError? error;
  final String message;
  final KeyPair? keyPair;
  final String? seedPhrase;

  const RecoveryResult({
    required this.success,
    this.error,
    required this.message,
    this.keyPair,
    this.seedPhrase,
  });
}

enum RecoveryError {
  invalidSeedPhrase,
  accountNotFound,
  serverError,
}

/// ==========================================
/// SEED ACCOUNT
/// ==========================================

class SeedAccount {
  final String seedPhrase;
  final KeyPair keyPair;
  final DateTime createdAt;

  const SeedAccount({
    required this.seedPhrase,
    required this.keyPair,
    required this.createdAt,
  });
}