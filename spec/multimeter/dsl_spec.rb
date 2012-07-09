require_relative '../spec_helper'


module Multimeter
  module Specs
    class ClassWithMetrics
      include Metrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end

    class ClassWithInstanceMetrics
      include InstanceMetrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end

    class ClassWithGlobalMetrics1
      include GlobalMetrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end

    class ClassWithGlobalMetrics2
      include GlobalMetrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end

    class ClassWithLinkedMetrics1
      include LinkedMetrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end

    class ClassWithLinkedMetrics2
      include LinkedMetrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end

    class ClassWithLinkedInstanceMetrics
      include LinkedInstanceMetrics

      counter :stuff

      def do_stuff
        stuff.inc
      end
    end
  end

  describe 'DSL' do
    describe Metrics do
      it 'scopes metrics to the class' do
        i1 = Specs::ClassWithMetrics.new
        i2 = Specs::ClassWithMetrics.new
        i1.do_stuff
        i1.do_stuff
        i2.do_stuff
        i1.stuff.count.should == 3
        i2.stuff.count.should == 3
      end
    end

    describe InstanceMetrics do
      it 'scopes metrics to each instance' do
        i1 = Specs::ClassWithInstanceMetrics.new
        i2 = Specs::ClassWithInstanceMetrics.new
        i1.do_stuff
        i1.do_stuff
        i2.do_stuff
        i1.stuff.count.should == 2
        i2.stuff.count.should == 1
      end
    end

    describe GlobalMetrics do
      it 'scopes metrics to each instance' do
        i1 = Specs::ClassWithGlobalMetrics1.new
        i2 = Specs::ClassWithGlobalMetrics2.new
        i1.do_stuff
        i1.do_stuff
        i2.do_stuff
        i1.stuff.count.should == 3
        i2.stuff.count.should == 3
        Multimeter.global_registry.get(:stuff).count.should == 3
      end
    end

    describe LinkedMetrics do
      it 'scopes metrics to the class, but registers the registry in a global hierarchy' do
        i1 = Specs::ClassWithLinkedMetrics1.new
        i2 = Specs::ClassWithLinkedMetrics2.new
        i1.do_stuff
        i1.do_stuff
        i2.do_stuff
        Multimeter.global_registry.sub_registry('ClassWithLinkedMetrics1').get(:stuff).count.should == 2
        Multimeter.global_registry.sub_registry('ClassWithLinkedMetrics2').get(:stuff).count.should == 1
      end
    end

    describe LinkedInstanceMetrics do
      it 'scopes metrics to the instance, but registers the registry in a global hierarchy' do
        i1 = Specs::ClassWithLinkedInstanceMetrics.new
        i2 = Specs::ClassWithLinkedInstanceMetrics.new
        i1.do_stuff
        i1.do_stuff
        i2.do_stuff
        all_registries = Multimeter.global_registry.sub_registries
        instance_registries = all_registries.select { |r| r.scope.start_with?('ClassWithLinkedInstanceMetrics') }
        instance_registries.should have(2).items
        instance_registries[0].get(:stuff).count.should == 2
        instance_registries[1].get(:stuff).count.should == 1
      end
    end
  end
end
