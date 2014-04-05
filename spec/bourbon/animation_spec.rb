require 'spec_helper'

describe "animation" do
  before(:all) do
    ParserSupport.parse_file('animation')
  end

  describe "@include animation" do
    context "with arguments (scale 1.0s ease-in, slide 2.5s ease)" do
      it "outputs with vendor prefixes" do
        expect('.animation-shorthand').to have_rule('-webkit-animation: scale 1s ease-in, slide 2.5s ease')
        expect('.animation-shorthand').to have_rule('-moz-animation: scale 1s ease-in, slide 2.5s ease')
        expect('.animation-shorthand').to have_rule('animation: scale 1s ease-in, slide 2.5s ease')
      end
    end
  end

  describe "@include animation-name" do
    context "with arguments (scale, slide)" do
      it "outputs with vendor prefixes" do
        expect('.animation-name').to have_rule('-webkit-animation-name: scale, slide')
        expect('.animation-name').to have_rule('-moz-animation-name: scale, slide')
        expect('.animation-name').to have_rule('animation-name: scale, slide')
      end
    end
  end

  describe "@include animation-duration" do
    context "with argument (2s)" do
      it "outputs with vendor prefixes" do
        expect('.animation-duration').to have_rule('-webkit-animation-duration: 2s')
        expect('.animation-duration').to have_rule('-moz-animation-duration: 2s')
        expect('.animation-duration').to have_rule('animation-duration: 2s')
      end
    end
  end

  describe "@include animation-timing-function" do
    context "with argument (ease)" do
      it "outputs with vendor prefixes" do
        expect('.animation-timing-function').to have_rule('-webkit-animation-timing-function: ease')
        expect('.animation-timing-function').to have_rule('-moz-animation-timing-function: ease')
        expect('.animation-timing-function').to have_rule('animation-timing-function: ease')
      end
    end
  end

  describe "@include animation-iteration-count" do
    context "with argument(infinite)" do
      it "outputs with vendor prefixes" do
        expect('.animation-iteration-count').to have_rule('-webkit-animation-iteration-count: infinite')
        expect('.animation-iteration-count').to have_rule('-moz-animation-iteration-count: infinite')
        expect('.animation-iteration-count').to have_rule('animation-iteration-count: infinite')
      end
    end
  end
end
