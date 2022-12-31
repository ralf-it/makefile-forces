#!██████████████████████████████████████████████████████████████████████████████████████████████████
#!███ Alters the make to work as `make <target> *args... -- **kwargs`
#!███ (Parallelism is disabled)
#!██████████████████████████████████████████████████████████████████████████████████████████████████

%-terraform:
	if echo "$(ARGV0)" | grep  --quiet -E -- '-terraform-|-tf-';
	then

		touch .make/.datetime # ! file need to exist for grep (fails in CICD)
		if ! grep -q "$(DATETIME0)" .make/.datetime; ## ! render only once
		then

			# echo "Undefined target: $@"
			# echo "MAKECMDGOALS: $(MAKECMDGOALS)"
			# echo "ARGV: $(ARGV)"
			# echo "ARGV0: $(ARGV0)"
			# echo "ARGVN: $(ARGVN)"
			# echo "*=$*"
			# echo "%=$%"
			# echo "<=$<"

			#!======================================================================================
			#!███ Copy terraform templates
			#!======================================================================================
			if [ -d "terraform/configs" ]; then
				for d in terraform/configs/*; do
					if [ -d "$$d" ]; then
						echo find $$d \
							-type f \
							-name "*.TPL" \
							-exec bash -c \
								'cp -n "$$1" "$${1%.TPL}"' \
							_ {} \;
					fi
				done
			fi

			fi

			echo $(DATETIME0) > .make/.datetime
		fi

		if [ "$(ARGV0)" != "$(MAKECMDGOALS)" ]; then # ! NOTE: disable parallelism, change behaviour of make TGT1 TG2 to make TGT1 ARGS...
			exit 0
		fi
	fi

	@:

