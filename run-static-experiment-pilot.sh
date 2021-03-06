#!/bin/bash

read -d '' 'JOB_SCRIPT' << EOF
#!/bin/sh

# Note that "#PBS" is not a comment, but "# PBS" is (note the space after "#")
#
# For more details, See the \`qsub\` manpage, or
# http://docs.adaptivecomputing.com/torque/4-1-3/Content/topics/commands/qsub.htm

# JOB NAME
#
#PBS -N pbs-static-pilot

# QUEUE NAME
#
#PBS -q justinli

# RESOURCES
#
# Example: #PBS -l nodes=4:ppn=8,mem=2000mb,file=40gb
# syntax: number_of_nodes:processors_per_node:node_feature_1:node_feature_2[:feature3...],memory,disk,etc.
#
#PBS -l nodes=n006.cluster.com:ppn=1,mem=1000mb,file=1gb

# EXPORT ENVIRONMENT
#
#PBS -V

# RERUNABLE FLAG
#
# Change to y to make job rerunable
#
#PBS -r n


# PBS environment variables:
#  PBS_O_LOGNAME    is the user who started the job
#  PBS_O_HOST       is the host on which the job is started
#  PBS_O_WORKDIR    is the directory in which the job is started
#  PBS_NODEFILE     is the file with the names of the nodes to run on
#  PBS_JOBID        is the jobid of the pbs job
#  PBS_JOBNAME      is the jobname of the pbs job
#  PBS_QUEUE        is the queue-name in which the job runs
# some important local environment variables:
#  PBS_L_RUNDIR     is the directory in which the job is running
#  PBS_L_NODENAME   is the (first) host on which the job runs
#  PBS_L_NODENUMBER is the number of nodes on which the job runs
#  PBS_L_GLOBALWORK is the global work directory of the cluster
#  PBS_L_LOCALWORK  is the local work directory of the cluster

PBS_L_NODENUMBER=\`wc -l < $PBS_NODEFILE\`

# Function to echo informational output
pbs_infoutput() {
	# Informational output
	echo "=================================== PBS JOB ==================================="
	date
	echo
	echo "The job will be started on the following node(s):"
	cat "\${PBS_NODEFILE}"
	echo
	echo "PBS User:           \$PBS_O_LOGNAME"
	echo "Job directory:      \$PBS_L_RUNDIR"
	echo "Job-id:             \$PBS_JOBID"
	echo "Jobname:            \$PBS_JOBNAME"
	echo "Queue:              \$PBS_QUEUE"
	echo "Number of nodes:    \$PBS_L_NODENUMBER"
	echo "PBS startdirectory: \$PBS_O_HOST:\$PBS_O_WORKDIR"
	echo "=================================== PBS JOB ==================================="
	echo
}

pbs_startjob() {
	###################
	# This is where your job script goes. 
	# If you use /work/username as a work directory, make sure to clean it up!
	###################

	VENV="/home/justinnhli/.venv/rdfwrap"

	cd "\$PBS_O_WORKDIR" && \
	source "\$VENV/bin/activate" && \
	python3 static-pilot-main.py \${random_seed_index}
	deactivate
}

pbs_infoutput

pbs_startjob
EOF

for random_seed_index in $(seq 0 4); do
	echo "$JOB_SCRIPT" | qsub -v random_seed_index="$random_seed_index" -
done
