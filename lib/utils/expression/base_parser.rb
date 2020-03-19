# frozen_string_literal: false

module Expression
  class BaseParser
    def initialize(exp, field, prd = %w[AND OR])
      @char_array = exp.chars
      @exp_array = ['(']
      @field_name = field
      @precedence = prd
      char_to_exp
    end

    attr_accessor :char_array, :exp_array, :field_name, :precedence

    def valid?
      valid_bracket_conunt? &&
        valid_element_sequence?
    end

    def dsl
      array_to_dsl
    end

    private 

    def valid_bracket_conunt?
      exp_array.count('(') == exp_array.count(')')
    end

    def valid_element_sequence?
      exp_array.each_with_index do |v, _|
        if %w[AND OR].include?(v) && (%w[AND OR].include?(exp_array[_ - 1]) || %w[AND OR].include?(exp_array[_ + 1]))
          return false
        end
      end
      true
    end

    def char_to_exp
      index = 0
      while index < char_array.count
        jump = index + 1
        if char_array[index] == '(' || char_array[index] == ')'
          exp_array << char_array[index]
        elsif char_array[index] == '"' || char_array[index] == ' '
          jump = process_char(jump, char_array[index])
        else
          jump = process_other_char(index)
        end
        index = jump
      end
      exp_array << ')'
    end

    def process_other_char(index)
      str = ''
      while char_array[index] != ' ' && index < char_array.count && char_array[index] != ')'
        str << char_array[index]
        index += 1
      end
      exp_array << content_parser(str)

      index
    end

    def process_char(index, char)
      str = ''
      while char_array[index] != char && index < char_array.count
        str << char_array[index]
        index += 1
      end
      exp_array << (%w[OR AND].include?(str) ? str : content_parser(str))
      index + 1
    end

    def array_to_dsl
      stack = []
      stack_ptr = 0
      ob_array_ptr = []
      exp_array.each do |x|
        if x == ')'
          ptr = ob_array_ptr.pop
          dsl = subarray_dsl(stack[(ptr + 1)..stack_ptr])
          stack.pop(stack_ptr - ptr)
          stack << dsl
          stack_ptr = ptr + 1
        else
          stack << x
          ob_array_ptr << stack_ptr if x == '('
          stack_ptr += 1
        end
      end
      subarray_dsl(stack)
    end

    def or_parser(val1, val2)
      "(#{val1} OR #{val2})"
    end

    def and_parser(val1, val2)
      "(#{val1} AND #{val2})"
    end

    def content_parser(val)
      "content ILIKE '%#{val}%'"
    end

    def parse(sub, opt)
      start = 0
      dsl = []
      while start < sub.count
        if  sub[start] == opt
          prev_val = dsl.pop
          dsl << send("#{opt.downcase}_parser", prev_val, sub[start + 1])
          start += 1
        else
          dsl << sub[start]
        end

        start += 1
      end
      dsl
    end

    def subarray_dsl(sub)
      start = 0
      precedence.each do |prd|
        sub = parse(sub, prd)
      end
      sub[0]
    end
  end
end
