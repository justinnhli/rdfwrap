from os.path import dirname, join as join_path, realpath

from rdfwrap import NXRDF

DIRECTORY = dirname(realpath(__file__))

COLOR_NAMES_FILE = join_path(DIRECTORY, 'color-centroids.tsv')

class Color:
    def __init__(self, r, g, b, name=None):
        self.r = r
        self.g = g
        self.b = b
        self.name = name
    def __hash__(self):
        return hash(str(self))
    def __str__(self):
        return '#{:02x}{:02x}{:02x}'.format(self.r, self.g, self.b).upper()
    def __repr__(self):
        if self.name is not None:
            return 'Color({}, {}, {}, name={})'.format(self.r, self.g, self.b, repr(self.name))
        else:
            return 'Color({}, {}, {})'.format(self.r, self.g, self.b)
    def __eq__(self, other):
        return str(self) == str(other)
    def __sub__(self, other):
        return abs(self.r - other.r) + abs(self.g - other.g) + abs(self.b - other.b)
    @staticmethod
    def from_hex(hexcode, name=None):
        if len(hexcode) == 7 and hexcode[0] == '#':
            hexcode = hexcode[1:]
        return Color(*(int(hexcode[i:i+2], 16) for i in range(0, 5, 2)), name=name)

def read_colors():
    colors = []
    with open(COLOR_NAMES_FILE) as fd:
        for line in fd:
            line = line.strip()
            if line[0] == '#':
                continue
            count, name, hexcode = line.split('\t')
            assert name, 'Colors must have a name, but only got hex: {}'.format(hexcode)
            colors.append(Color.from_hex(hexcode, name))
    return colors

COLOR_CACHE = read_colors()

def create_knn_dot(num_colors, k):
    dot = []
    dot.append('digraph {')
    dot.append('  layout="neato"')
    dot.append('  overlap="scalexy"')
    colors = COLOR_CACHE[:num_colors]
    for color in colors:
        dot.append('  "{hexcode}" [label="{name}\\n{hexcode}", style="filled", fillcolor="{hexcode}"]'.format(name=color.name, hexcode=str(color)))
        neighbors = [[neighbor, color - neighbor] for neighbor in colors if neighbor != color]
        neighbors = sorted(neighbors, key=(lambda kv: kv[1]))[:k]
        for neighbor, distance in neighbors:
            dot.append('  "{}" -> "{}" [label="{}"]'.format(str(color), str(neighbor), distance))
    dot.append('}')
    return '\n'.join(dot)

def create_knn(num_colors, k, graph=None):
    if graph is None:
        graph = NXRDF()
    colors = COLOR_CACHE[:num_colors]
    node_map = {}
    for color in colors:
        color_node = graph.add_node()
        node_map[color] = color_node
        graph.add_edge(color_node, 'name', graph.add_literal(color.name))
        graph.add_edge(color_node, 'hexcode', graph.add_literal(str(color)))
        graph.add_edge(color_node, 'r', graph.add_literal(color.r))
        graph.add_edge(color_node, 'g', graph.add_literal(color.g))
        graph.add_edge(color_node, 'b', graph.add_literal(color.b))
    for color in colors:
        neighbors = [[neighbor, color - neighbor] for neighbor in colors if neighbor != color]
        neighbors = sorted(neighbors, key=(lambda kv: kv[1]))[:k]
        for neighbor, distance in neighbors:
            graph.add_edge(node_map[color], 'neighbor', node_map[neighbor])
    return graph

def closest_color(color, num_colors):
    return min(COLOR_CACHE[:num_colors], key=(lambda neighbor: neighbor - color))

def find_label_index(label):
    matching = [index for index, color in enumerate(COLOR_CACHE) if color.name.lower() == label.lower()]
    if matching:
        return matching[0]
    return None
